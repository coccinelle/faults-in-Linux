create or replace function study_nb_buckets() returns int
    language sql STABLE
    as $$select 6$$;

--
-- The study_rate_version will be overwritten
-- by figures/get_error_rate_by.sh
--
create or replace function study_rate_version() returns VarChar(256)
    language sql STABLE
    as
	  	$$select 'linux-3.0'::VarChar(256)$$;
--	  	$$select 'linux-2.6.39'::VarChar(256)$$;
--	  	$$select 'linux-2.6.33'::VarChar(256)$$;

-- drop view bucket_file_by_churn_s cascade;
create or replace view bucket_file_by_churn_s as
select f.version_name,
			 v.release_date,
			 f.file_id,
			 f.nb_mods as file_churn,
       do_exp_bucket(row_number() over (partition by f.version_name order by f.nb_mods), study_nb_buckets(), v.number_of_files) as bucket
       from files f
       join full_versions v on v.version_name=f.version_name
			 order by f.version_name, bucket, f.nb_mods;

-- drop view bucket_file_by_age_s cascade;
create or replace view bucket_file_by_age_s as
select f.version_name,
			 f.release_date,
			 f.file_id,
			 f.age_in_days,
       do_exp_bucket(row_number() over (partition by f.version_name order by f.age_in_days), study_nb_buckets(), f.number_of_files) as bucket
       from (select v.version_name,
			 							v.release_date,
			 							v.number_of_files,
			 							f.file_id,
			 							v.release_date - fn.birth_date as age_in_days
			 							from files f
			 							join full_versions v on v.version_name=f.version_name
			 							join full_file_names fn on fn.file_name=f.file_name) as f
			 order by f.version_name desc, bucket, f.age_in_days;

-- drop view rate_by_churns cascade;
create or replace view rate_per_churns as
select b.version_name,
			 b.release_date,
			 b.bucket,
			 t.average_churn,
			 t.min_churn,
			 t.max_churn,
			 t.nb_files_per_bucket,
			 round(100*b.number_of_bugs::numeric/b.number_of_notes, 2) as rate_in_percentage,
			 b.number_of_bugs,
			 b.number_of_notes
			 from (select b.version_name,
			 							b.release_date,
			 							b.bucket,
			 							sum(r.number_of_bugs) as number_of_bugs,
			 							sum(r.number_of_notes) as number_of_notes
			 							from rate_per_files r
			 							join bucket_file_by_churn_s b on r.file_id=b.file_id
			 							group by b.version_name, b.release_date, b.bucket) as b
			 join (select b.version_name,
							 			b.bucket,
							 			round(avg(b.file_churn), 2) as average_churn,
							 			min(b.file_churn) as min_churn,
							 			max(b.file_churn) as max_churn,
							 			count(b.file_id)  as nb_files_per_bucket
							 			from bucket_file_by_churn_s b
							 			group by b.version_name, b.bucket
							 			order by b.version_name) as t
					on b.bucket=t.bucket and b.version_name=t.version_name
			 order by b.release_date, b.bucket;

-- drop view rate_by_ages cascade;
create or replace view rate_per_ages as
select b.version_name,
			 b.release_date,
			 b.bucket,
			 round(t.average_age::numeric/365.25, 2) as average_age_in_years,
			 round(t.min_age::numeric/365.25, 2) as min_age_in_years,
			 round(t.max_age::numeric/365.25, 2) as max_age_in_years,
			 t.nb_files_per_bucket,
			 round(100*b.number_of_bugs::numeric/b.number_of_notes, 2) as rate_in_percentage,
			 b.number_of_bugs,
			 b.number_of_notes
			 from (select b.version_name,
			 							b.release_date,
			 							b.bucket,
			 							sum(r.number_of_bugs) as number_of_bugs,
			 							sum(r.number_of_notes) as number_of_notes
			 							from rate_per_files r
			 							join bucket_file_by_age_s b on r.file_id=b.file_id
			 							group by b.version_name, b.release_date, b.bucket) as b
			 join (select b.version_name,
							 			b.bucket,
							 			round(avg(b.age_in_days), 2) as average_age,
							 			min(b.age_in_days) as min_age,
							 			max(b.age_in_days) as max_age,
							 			count(b.file_id)  as nb_files_per_bucket
							 			from bucket_file_by_age_s b
							 			group by b.version_name, b.bucket
							 			order by b.version_name) as t
					on b.bucket=t.bucket and b.version_name=t.version_name
			 order by b.release_date, b.bucket;


-- drop view rate_per_function_restrict_s cascade;
create or replace view study_rate_per_function_restrict_s as
select v.version_name,
			 v.release_date,
			 func.function_id,
			 b.count as number_of_bugs,
			 n.count as number_of_notes,
			 round(100*coalesce(b.count, 0)::numeric/coalesce(n.count, 1), 2) as rate_in_percentage
			 from functions func
			 join files f on f.file_id=func.file_id
			 join versions v on v.version_name=f.version_name and v.version_name=study_rate_version()
			 left outer join
			 			(select func.function_id,
										count(b.report_id)
										from standard_bugs b
										join functions func on b.file_id=func.file_id and b.line_no between func.start and func.finish
										where has_notes(b.standardized_name)
										group by func.function_id) as b on b.function_id=func.function_id
			 left outer join
			 			(select func.function_id,
										count(n.note_id)
										from standard_notes n
										join functions func on n.file_id=func.file_id and n.line_no between func.start and func.finish
										group by func.function_id) as n on n.function_id=func.function_id
			 order by v.release_date desc;

-- drop view bucket_function_by_length_restrict_s;
create or replace view study_bucket_function_by_length_restrict_s as
select v.version_name,
			 v.release_date,
			 func.*,
			 do_exp_bucket(row_number() over (partition by f.version_name order by func.length), study_nb_buckets(), t.number_of_functions)
			 																 as bucket
			 from (select func.*, func.finish - func.start + 1 as length from functions func) as func
			 join files f on func.file_id=f.file_id
			 join versions v on f.version_name=v.version_name and v.version_name=study_rate_version()
			 join (select v.version_name, count(func.function_id) as number_of_functions
					 					from versions v
					 					join files f on f.version_name=v.version_name
					 					join functions func on f.file_id=func.file_id
					 					group by v.version_name) as t
					on t.version_name=v.version_name
			 order by v.release_date, bucket, func.length;

-- drop view rate_by_fct_size_restrict_s cascade;
create or replace view study_rate_per_fct_size_restrict_s as
select b.version_name,
			 b.release_date,
			 b.bucket,
			 t.average_fct_size,
			 t.min_fct_size,
			 t.max_fct_size,
			 t.nb_fncs_per_bucket,
			 round(100*b.number_of_bugs::numeric/b.number_of_notes, 2) as rate_in_percentage,
			 b.number_of_bugs,
			 b.number_of_notes
			 from (select b.version_name,
			 							b.release_date,
			 							b.bucket,
			 							sum(r.number_of_bugs) as number_of_bugs,
			 							sum(r.number_of_notes) as number_of_notes
			 							from study_rate_per_function_restrict_s r
			 							join study_bucket_function_by_length_restrict_s b on r.function_id=b.function_id
			 							group by b.version_name, b.release_date, b.bucket) as b
			 join (select b.version_name,
							 			b.bucket,
							 			round(avg(b.length), 2) as average_fct_size,
							 			min(b.length) as min_fct_size,
							 			max(b.length) as max_fct_size,
 										-- Nico: Is the count of file_id really equal to the nb of fncs in the bucket ?
										count(b.file_id)  as nb_fncs_per_bucket
							 			from study_bucket_function_by_length_restrict_s b
							 			group by b.version_name, b.bucket
							 			order by b.version_name) as t
					on b.bucket=t.bucket and b.version_name=t.version_name
			 order by b.release_date, b.bucket;
