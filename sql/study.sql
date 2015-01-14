--
-- Give a fixed date to compute age of files
--
-- drop function today() cascade;
create or replace function study_first_release() returns date
    LANGUAGE sql STABLE
    AS $$select '2003-12-18'::date$$;  -- 2.6.0

create or replace function study_futur_release() returns date
    LANGUAGE sql STABLE
--    AS $$select '2010-05-16'::date$$;  -- 2.6.34
--    AS $$select '2011-05-18'::date$$;  -- 2.6.39
--    AS $$select '2011-07-22'::date$$;  -- 3.0
    AS $$select '2011-10-24'::date$$;  -- 3.1

-- drop view study_dirnames_241 cascade;
create or replace view study_dirnames_241 as
 select *
 				from study_dirnames
 				where study_dirname!='sound' and study_dirname!='staging';

--
-- fig 1
--
-- drop view study_fig_study_dirname_size_cumulatives cascade;
create or replace view study_fig_dirname_cumulative_sizes as select * from study_dirname_cumulative_sizes;

--
-- fig 2
--
-- drop view study_fig_study_dirname_size_evolutions cascade;
create or replace view study_fig_dirname_evolution_sizes as
select * from study_dirname_evolution_sizes
			 	 where linux_gt(version_name, 'linux-2.6.0')
				 and study_dirname!='staging';

--
-- fig 3 and 22
--
-- drop view study_fig_number_of_notes_in_26 cascade;
create or replace view study_fig_notes_in_26 as
select standardized_name, version_name, release_date, coalesce(number_of_notes, coalesce(number_of_bugs, 0)) as number_of_notes
			 from rate_per_ver_cat_s
			 where linux_ge(version_name, 'linux-2.6.0')
			 and has_notes(standardized_name)
			 order by release_date;

--
-- table 3
--
-- -- drop view study_fig_bugs_in_241;
create or replace view study_fig_bugs_in_241 as
select r.standardized_name, coalesce(r.number_of_bugs, 0)
 			 from bugs_per_ver_cat_s r
			 where r.version_name='linux-2.4.1' and not is_rcu(r.standardized_name);

--
-- fig 4.a
--
-- drop view study_fig_bugs_per_directory_and_category_in_241 cascade;
create or replace view study_fig_bugs_per_dir_cat_in_241 as
select b.study_dirname,
 			 b.standardized_name,
			 coalesce(b.number_of_bugs, 0) as number_of_bugs
			 from bugs_per_ver_dir_cat_s b
			 join study_dirnames_241 d on b.study_dirname=d.study_dirname
			 where version_name='linux-2.4.1' and not is_rcu(standardized_name);

--
-- fig 4.b
--
-- drop view study_fig_rel_rate_per_dir_cat_in_241 cascade;
create or replace view study_fig_rel_rate_per_dir_cat_in_241 as
select r.study_dirname,
			 r.standardized_name,
			 r.relative_rate_in_percentage
			 from relative_rate_per_ver_dir_cat_s r join study_dirnames_241 d on r.study_dirname=d.study_dirname
			 where version_name='linux-2.4.1' and not is_rcu(standardized_name) and has_notes(standardized_name);

--
-- fig 5
--
-- drop view study_fig_faulty_files_per_nb_bugs_241 cascade;
create or replace view study_fig_faulty_files_per_nb_bugs_241 as
select f.number_of_bugs_in_file,
			 count(f.file_id) as number_of_faulty_files
 			 from (select b.file_id, count(b.report_id) as number_of_bugs_in_file
 			 							from standard_bugs b
										join files f on f.file_id=b.file_id
										where f.version_name='linux-2.4.1' and not is_rcu(b.standardized_name)
 			 							group by b.file_id) as f
 			 group by f.number_of_bugs_in_file
 			 order by f.number_of_bugs_in_file;

--
-- fig 6.a
--
-- drop view study_fig_bugs_no_rcu_per_ver_26 cascade;
create or replace view study_fig_bugs_no_rcu_per_ver_26 as
select version_name, release_date, coalesce(sum(number_of_bugs), 0) as number_of_bugs
			 from bugs_per_ver_cat_s
			 where linux_ge(version_name, 'linux-2.6.0') and not is_rcu(standardized_name)
			 group by version_name, release_date
			 order by release_date;

--
-- fig 6.b
--
-- drop view study_fig_bugs_no_rcu_per_ver_kloc_26 cascade;
create or replace view study_fig_bugs_no_rcu_per_ver_kloc_26 as
select b.version_name,
			 b.release_date,
			 round(1000*b.number_of_bugs::numeric/v.locc, 4) as faults_per_kloc
			 from study_fig_bugs_no_rcu_per_ver_26 b
			 join versions v on v.version_name=b.version_name
			 group by b.version_name, b.release_date, b.number_of_bugs, v.locc
			 order by b.release_date;

--
-- fig 6.c
--
-- drop view study_fig_bugs_no_rcu_intro_elim_per_ver_26 cascade;
create or replace view study_fig_bugs_no_rcu_intro_elim_per_ver_26 as
select version_name, release_date, sum(number_of_new_bugs) as number_of_new_bugs, sum(number_of_removed_bugs) as number_of_removed_bugs
			 from bugs_intro_elim_per_ver_cat_s
			 where linux_gt(version_name, 'linux-2.6.0') and not is_rcu(standardized_name)
			 group by version_name, release_date
			 order by release_date;

--
-- fig 7
--
-- drop view study_fig_bugs_no_rcu_per_ver_cat_in_26 cascade;
create or replace view study_fig_bugs_no_rcu_per_ver_cat_in_26 as
select standardized_name, version_name, release_date, coalesce(number_of_bugs, 0)
			 from bugs_per_ver_cat_s
			 where linux_ge(version_name, 'linux-2.6.0') and not is_rcu(standardized_name);

--
-- fig 8
--
-- drop view study_fig_rate_no_rcu_by_ver_cat_26 cascade;
create or replace view study_fig_rate_no_rcu_by_ver_cat_26 as
select standardized_name, version_name, release_date, rate_in_percentage
			 from rate_per_ver_cat_s
			 where linux_ge(version_name, 'linux-2.6.0') and not is_rcu(standardized_name) and has_notes(standardized_name);

--
-- fig 9
--
-- drop view study_fig_faults_no_rcu_by_ver_dir_26 cascade;
create or replace view study_fig_faults_no_rcu_by_ver_dir_26 as
-- select study_dirname, version_name, release_date, coalesce(sum(number_of_bugs), 0) as number_of_bugs -- gives 0 when there is no data
select study_dirname, version_name, release_date, sum(number_of_bugs) as number_of_bugs -- gives NULL when there is no data (cut curve, ie for staging)
			 from bugs_per_ver_dir_cat_s
			 where linux_ge(version_name, 'linux-2.6.0') and not is_rcu(standardized_name)
			 and number_of_bugs >= 0 -- to use with null value
			 group by study_dirname, version_name, release_date
			 order by study_dirname, release_date;

--
-- fig 10
--
-- drop view study_fig_rate_no_rcu_by_ver_dir_26 cascade;
create or replace view study_fig_rate_no_rcu_by_ver_dir_26 as
select study_dirname, version_name, release_date, sum(number_of_bugs) as bugs,
			 round(100*coalesce(sum(number_of_bugs), 0)::numeric/coalesce(sum(number_of_notes), coalesce(sum(number_of_bugs), 1)),2)
			 				as rate_in_percentage
			 from rate_per_ver_dir_cat_s
			 where linux_ge(version_name, 'linux-2.6.0') and not is_rcu(standardized_name) and has_notes(standardized_name)
			 group by study_dirname, version_name, release_date
			 order by study_dirname, release_date;

--
-- fig 11
--
-- drop view study_fig_rel_rate_per_dir_cat_2639 cascade;
create or replace view study_fig_rel_rate_per_dir_cat_2639 as
select r.study_dirname,
			 r.standardized_name,
			 r.relative_rate_in_percentage
			 from relative_rate_per_ver_dir_cat_s r
			 where version_name='linux-2.6.39' and not is_rcu(standardized_name) and has_notes(standardized_name);

create or replace view study_fig_rel_rate_per_dir_cat_30 as
select r.study_dirname,
			 r.standardized_name,
			 r.relative_rate_in_percentage
			 from relative_rate_per_ver_dir_cat_s r
			 where version_name='linux-3.0' and not is_rcu(standardized_name) and has_notes(standardized_name);

--
-- fig 12
--
-- drop view study_fig_avg_bugs_per_file_in_dir_26 cascade;
create or replace view study_fig_avg_bugs_per_file_in_dir_26 as
select fn.study_dirname,
			 v.version_name,
			 v.release_date,
			 round(avg(b.count), 2)
			 from (select file_id, count(report_id) from standard_bugs where not is_rcu(standardized_name) group by file_id) as b
			 join files f on b.file_id = f.file_id
			 join file_names fn on f.file_name = fn.file_name
			 join versions v on v.version_name = f.version_name
			 where linux_ge(v.version_name, 'linux-2.6.0')
			 group by fn.study_dirname, v.version_name, v.release_date
			 order by fn.study_dirname, v.release_date;


--
--   helper to construcy the list of relevent bugs considered for life span figures
--
-- drop view study_helper_considered_bugs_for_lifespan cascade;
create or replace view study_helper_considered_bugs_for_lifespan as
select c.correlation_id,
			 c.file_name,
			 c.standardized_name,
			 c.study_dirname,
			 c.correlation_birth_date,
			 c.correlation_death_date,
			 coalesce(c.correlation_death_date, study_futur_release()) - c.correlation_birth_date as life_in_days
			 from full_bug_correlations c
			 where not is_rcu(c.standardized_name)
  			 and linux_ge(c.correlation_birth_version, 'linux-2.6.0');

create or replace view study_helper_considered_bugs_for_lifespan_wo_staging as
select c.correlation_id,
			 c.file_name,
			 c.standardized_name,
			 c.study_dirname,
			 c.correlation_birth_date,
			 c.correlation_death_date,
			 coalesce(c.correlation_death_date, study_futur_release()) - c.correlation_birth_date as life_in_days
			 from full_bug_correlations c
			 where c.study_dirname!='staging'
			 and not is_rcu(c.standardized_name)
  			 and linux_ge(c.correlation_birth_version, 'linux-2.6.0');

create or replace view study_helper_bugs_per_life_dir as
select study_dirname,
			 life_in_days,
			 count(correlation_id) as number_of_bugs
			 from study_helper_considered_bugs_for_lifespan
			 group by study_dirname, life_in_days
			 order by study_dirname, life_in_days;

--
-- for fig 13.a and 13.b
--
-- drop view study_helper_avg_bugs_life cascade;
create or replace view study_helper_avg_bugs_life as
select round(avg(life_in_days)::numeric/365.25, 2) as avg_bug_life
			 from study_helper_considered_bugs_for_lifespan_wo_staging;

--
-- fig 13.a
--
-- drop view study_fig_bugs_life_per_dir cascade;
create or replace view study_fig_bugs_life_per_dir as
select study_dirname,
			 count(life_in_days) as number_of_bugs,
 			 round(avg(life_in_days)::numeric/365.25, 2) as avg_bug_life_in_years
			 from study_helper_considered_bugs_for_lifespan
--			 from study_helper_considered_bugs_for_lifespan_wo_staging
			 group by study_dirname;

--
-- fig 13.b
--
-- drop view study_fig_bugs_life_per_cat_no_rcu_no_staging_26 cascade;
create or replace view study_fig_bugs_life_per_cat as
select a.difficulty,
			 count(c.life_in_days) as number_of_bugs,
 			 round(avg(c.life_in_days)::numeric/365.25, 2) as avg_bug_life_in_years
			 from study_helper_considered_bugs_for_lifespan_wo_staging c
			 join (values
							('Var',       'EEL'), ('IsNull',    'EEL'), ('Range',    'EEL'),
							('Lock',      'EEH'), ('Intr',      'EEH'), ('LockIntr', 'EEH'),
							('NullRef',   'EHL'), ('Float',     'EHH'), ('Free',     'HEH'),
							('BlockLock', 'HHL'), ('BlockIntr', 'HHL'), ('Null',     'HHL')) as a(standardized_name, difficulty)
					  on a.standardized_name=c.standardized_name
			 --JOIN ( VALUES (1,'EEL'::text), (2,'EEH'::text), (3,'EHL'::text),
			 --	  	 (4,'EHH'::text), (5,'HEH'::text), (6,'HHL'::text))
			 --		 b(difforder, difficulty) ON a.difficulty = b.difficulty
			 --GROUP BY a.difficulty, b.difforder
			 --ORDER BY b.difforder;	
			 group by a.difficulty;

--
-- fig 14
--
-- drop view study_fig_cumulative_bugs_per_life_dir cascade;
create or replace view study_fig_cumulative_bugs_per_life_dir as
select b.study_dirname,
			 round(b.life_in_days/365.25, 2) as life_in_years,
			 sum(c.number_of_bugs) as cumulative_corrected_bugs,
			 round(100*sum(c.number_of_bugs)::numeric/t.number_of_bugs, 2) as percentage_of_corrected_bugs
			 from study_helper_bugs_per_life_dir b
			 join study_helper_bugs_per_life_dir c
			 			on b.study_dirname=c.study_dirname and c.life_in_days<=b.life_in_days
			 join study_fig_bugs_life_per_dir t
			 			on b.study_dirname=t.study_dirname
			 group by b.study_dirname, b.life_in_days, t.number_of_bugs
			 order by b.study_dirname, b.life_in_days;

--
-- fig 14
--
-- drop view study_fig_cumulative_bugs_per_life cascade;
create or replace view study_fig_cumulative_bugs_per_life as
select round(b.life_in_days/365.25, 2) as life_in_years,
			 sum(c.number_of_bugs) as cumulative_corrected_bugs,
			 round(100*sum(c.number_of_bugs)::numeric/t.sum, 2) as percentage_of_corrected_bugs
			 from (select sum(number_of_bugs) from study_fig_bugs_life_per_dir) as t,
			      (select life_in_days from study_helper_bugs_per_life_dir group by life_in_days) as b
			 join study_helper_bugs_per_life_dir c
			 on   c.life_in_days<=b.life_in_days
			 group by b.life_in_days, t.sum
			 order by b.life_in_days;

--
-- fig 15
--
-- drop view study_fig_bug_life_26
create or replace view study_fig_bug_life_26 as
select c.correlation_id,
	row_number() over (order by c.correlation_birth_date asc, c.correlation_death_date desc),
			 greatest(study_first_release(),c.file_birth_date) as file_birth_date,
			 c.correlation_birth_date,
			 c.correlation_death_date,
			 c.file_death_date,
			 (greatest(study_first_release(),c.file_birth_date) - study_first_release()) as file_birth,
			 (c.correlation_birth_date - study_first_release()) as bug_birth,
			 (COALESCE(c.correlation_death_date, study_futur_release()) - study_first_release()) as bug_death,
			 (COALESCE(c.file_death_date, study_futur_release()) - study_first_release()) as file_death
			 from full_bug_correlations c
			 where linux_ge(c.correlation_birth_version, 'linux-2.6.0') and not is_rcu(c.standardized_name)
			 order by c.correlation_birth_date asc, c.correlation_death_date desc;

--
-- fig 16
--
-- drop view study_fig_bugs_per_ver_through_ver_26;
create or replace view study_fig_bugs_per_ver_through_ver_26 as
select v1.version_name as reference_version_name,
			 v1.release_date as reference_release_date,
			 v2.version_name,
			 v2.release_date,
			 count(b2.report_id) as number_of_bugs
			 from standard_bugs b1
			 join files f1 on f1.file_id=b1.file_id
			 join versions v1 on f1.version_name=v1.version_name
			 join standard_bugs b2 on b2.correlation_id=b1.correlation_id
			 join files f2 on f2.file_id=b2.file_id
			 join versions v2 on f2.version_name=v2.version_name
			 where linux_ge(v1.version_name, 'linux-2.6.0') and linux_ge(v2.version_name, 'linux-2.6.0')
			 and not is_rcu(b1.standardized_name)
			 group by v1.version_name, v1.release_date, v2.version_name, v2.release_date
			 order by v1.release_date, v2.release_date;
