--------------------------------------------
--            standard views              --
--------------------------------------------
--
-- gives the correlation and its standardized_name, only consider usefull bugs
--
create or replace view standard_correlations as
select c.*, e.standardized_name
			 from correlations c
			 join error_names e      on e.report_error_name=c.report_error_name
			 join bug_categories cat on e.standardized_name=cat.standardized_name;

--
-- gives the note and its standardized_name, only consider usefull bugs
--
-- drop view standard_notes cascade;
create or replace view standard_notes as
select n.*, e.standardized_name
			 from notes n
			 join note_names e       on n.note_error_name=e.note_error_name
			 join bug_categories cat on e.standardized_name=cat.standardized_name;

--
-- gives the report and its standard_correlation
--
create or replace view standard_reports as
select r.report_id,
			 r.file_id,
 			 r.line_no,
 			 r.column_start,
 			 r.column_end,
 			 r.text_link      as report_text_link,
			 c.*
			 from reports r join standard_correlations c on c.correlation_id=r.correlation_id;

--
-- gives the correlations with status='BUG'
--
create or replace view standard_bug_correlations as
select c.* from standard_correlations c where c.status='BUG';

--
-- gives the bugs
--
create or replace view standard_bugs as
select r.* from standard_reports r where r.status='BUG';

--------------------------------------------
--            full views                  --
--------------------------------------------
--
-- gives the full versions: with the previous and next version
--
-- drop view full_versions cascade;
create or replace view full_versions as
select v.*,
			 (select v2.version_name from versions v2 where v2.release_date=w.max) as previous_version_name,
			 w.max as previous_release_date,
			 (select v2.version_name from versions v2 where v2.release_date=w.min) as next_version_name,
			 w.min as next_release_date,
			 nb.number_of_files,
			 v.release_date - w.max  as release_length
			 from
			  versions v
				join (select v.version_name, min(vn.release_date), max(vp.release_date)
			 							 from versions v
			 							 left outer join versions vn
			 							 			on v.release_date<vn.release_date
			 							 left outer join versions vp
			 							 			on v.release_date>vp.release_date
			 							 group by v.version_name) as w
					on v.version_name=w.version_name
				join (select v.version_name, count(f.file_id) as number_of_files
			 			 				 from versions v join files f on f.version_name=v.version_name group by v.version_name) as nb
					on v.version_name=nb.version_name
			 order by v.release_date;


--
-- Gives the full file names: birth and death of a file + the dir name
--
-- drop view full_file_names cascade;
create or replace view full_file_names as
select f.file_name,
			 fn.study_dirname,
			 v1.version_name as birth_version,
			 f.birth_date,
			 v2.version_name as last_version,
			 v2.release_date as last_date,
			 v2.next_version_name as death_version,
			 v2.next_release_date as death_date,
			 fn.family_name,
			 fn.type_name,
			 fn.impl_name,
			 fn.other_name
			 from
					(select   f.file_name,
										min(v.release_date) as birth_date,
										max(v.release_date) as death_date
			 							from files f
										join versions v on f.version_name=v.version_name
			 							group by f.file_name) as f
			 join file_names fn    on fn.file_name=f.file_name
			 join versions v1      on f.birth_date=v1.release_date
			 join full_versions v2 on f.death_date=v2.release_date;

--
-- Gives the full file: file + full_file_name + version
--
-- drop view full_files cascade;
create or replace view full_files as
select f.*,
			 v.release_date,
			 fn.study_dirname,
			 fn.birth_version as file_birth_version,
			 fn.birth_date    as file_birth_date,
			 fn.last_version  as file_last_version,
			 fn.last_date     as file_last_date,
			 fn.death_version as file_death_version,
			 fn.death_date    as file_death_date,
			 fn.family_name,
			 fn.type_name,
			 fn.impl_name,
			 fn.other_name,
			 v.main           as version_main,
			 v.major          as version_major,
			 v.minor          as version_minor,
			 v.commit_id      as version_commit_id,
			 v.locc           as version_locc
			 from files f
			 join full_file_names fn on f.file_name=fn.file_name
			 join full_versions v    on v.version_name=f.version_name;

--
-- gives the full correlations: standardized_name, birth of correlation and death of correlation
--
-- drop view full_correlations cascade;
create or replace view full_correlations as
select c.correlation_id,
			 d.file_name,
			 fn.study_dirname,
			 c.standardized_name,
 			 c.report_error_name,
 			 c.status,
			 c.reason_phrase,
 			 c.data_source,
			 c.birth_commit_number,
			 d.birth_date         as correlation_birth_date,
			 v1.version_name      as correlation_birth_version,
			 v2.release_date      as correlation_last_date,
			 v2.version_name      as correlation_last_version,
			 v2.next_release_date as correlation_death_date,
			 v2.next_version_name as correlation_death_version,
			 fn.birth_version     as file_birth_version,
			 fn.birth_date        as file_birth_date,
			 fn.last_version      as file_last_version,
			 fn.last_date         as file_last_date,
			 fn.death_version     as file_death_version,
			 fn.death_date        as file_death_date,
			 fn.family_name,
			 fn.type_name,
			 fn.impl_name,
			 fn.other_name
			 from
					(select c.correlation_id, f.file_name, min(f.release_date) as birth_date, max(f.release_date) as death_date
			 				from correlations c
			 				join reports r    on r.correlation_id=c.correlation_id
			 				join full_files f on r.file_id=f.file_id
			 				group by c.correlation_id, f.file_name) as d
			 join full_file_names fn      on d.file_name=fn.file_name
			 join standard_correlations c on c.correlation_id=d.correlation_id
			 join versions v1             on v1.release_date=d.birth_date
			 join full_versions v2        on v2.release_date=d.death_date;

--
-- gives the full reports: with its full correlation
--
-- drop view full_reports cascade;
create or replace view full_reports as
  select r.report_id,
				 r.file_id,
				 f.version_name,
				 v.release_date,
				 c.*,
  			 r.line_no,
  			 r.column_start,
  			 r.column_end,
  			 r.text_link      as report_text_link
  			 from full_correlations c
  			 join reports r   on c.correlation_id = r.correlation_id
				 join files f     on r.file_id=f.file_id
				 join versions v  on v.version_name=f.version_name;

--
-- only the bugs
--
-- drop view full_bugs cascade;
create or replace view full_bug_correlations as
select c.*,
       a.author_name,
       ct.author_name as committer_name
from full_correlations c
join standard_bug_correlations bc using (correlation_id)
join history h               on c.birth_commit_number = h.commit_id
join authors a               using (author_id)
join authors ct              on ct.author_id = h.committer_id;

--
-- only the bugs
--
-- drop view full_bugs cascade;
create or replace view full_bugs as
select r.* from full_reports r join standard_bug_correlations bc on bc.correlation_id=r.correlation_id;

--
-- gives the full note: only with its standardized_name
--
-- drop view full_notes cascade;
create or replace view full_notes as
select n.note_id,
			 n.data_source,
			 n.note_error_name,
			 n.standardized_name,
			 n.line_no,
			 n.column_start,
			 n.column_end,
			 n.text_link,
			 f.*
			 from standard_notes n
			 join full_files f on n.file_id=f.file_id;

--------------------------------------------
--            size data                   --
--------------------------------------------
--
-- study_dirname_sizes: gives the size of the dir names
--
-- drop view study_dirname_sizes cascade;
create or replace view study_dirname_sizes as
select v.version_name,
			 v.release_date,
 			 v.study_dirname,
 			 sum(f.file_size) as directory_size
			 from (select * from versions, study_dirnames) as v
			 left outer join (select * from files f
			 								 				 	 join file_names fn on f.file_name=fn.file_name) as f
						on  f.version_name=v.version_name
						and f.study_dirname=v.study_dirname
 			 group by v.version_name, v.release_date, v.study_dirname
			 order by v.release_date, v.study_dirname;

--
-- cumulate the directory sizes
--
-- drop view study_dirname_cumulative_sizes cascade;
create or replace view study_dirname_cumulative_sizes as
select b.version_name,
			 b.release_date,
			 b.study_dirname,
			 b.study_dirname_id,
			 coalesce(sum(p.directory_size), 0) as cummulative_directory_size
			 from (select s.*, d.study_dirname_id
			 							from study_dirname_sizes s join study_dirnames d on s.study_dirname=d.study_dirname) as b
			 join (select s.*, d.study_dirname_id
			 							from study_dirname_sizes s join study_dirnames d on s.study_dirname=d.study_dirname) as p
						on p.version_name=b.version_name
						and p.study_dirname_id<=b.study_dirname_id
			 group by b.version_name, b.release_date, b.study_dirname, b.study_dirname_id
			 order by b.release_date, b.study_dirname_id;

--
-- give the evolution in size per directory in percentage
--
-- drop view study_dirname_evolution_sizes cascade;
create or replace view study_dirname_evolution_sizes as
select s.version_name,
			 s.release_date,
			 s.study_dirname,
			 s.directory_size,
			 round(100*(s.directory_size - p.directory_size)::numeric/p.directory_size, 2) as evolution_in_percentage
			 from study_dirname_sizes s
			 join full_versions v on s.version_name=v.version_name
			 left outer join study_dirname_sizes p on p.version_name=v.previous_version_name and p.study_dirname=s.study_dirname
			 order by s.study_dirname, s.release_date;

--------------------------------------------
--    rate, reports and notes data        --
--------------------------------------------
-- drop view bugs_per_ver_dir_cat_s cascade;
create or replace view bugs_per_ver_dir_cat_s as
select v.version_name,
			 v.release_date,
			 v.study_dirname,
			 v.standardized_name,
			 b.count as number_of_bugs
			 from (select * from versions, study_dirnames, bug_categories) as v
			 left outer join
			 			(select f.version_name, fn.study_dirname, b.standardized_name, count(b.report_id)
										from standard_bugs b
										join files f       on f.file_id=b.file_id
										join file_names fn on fn.file_name=f.file_name
										group by f.version_name, fn.study_dirname, b.standardized_name) as b
						on v.version_name=b.version_name and v.study_dirname=b.study_dirname and v.standardized_name=b.standardized_name
			 order by v.release_date, v.study_dirname, v.standardized_name;

-- drop view bugs_per_ver_cat_s cascade;
create or replace view bugs_per_ver_cat_s as
select v.standardized_name,
			 v.version_name,
			 v.release_date,
			 b.count as number_of_bugs
			 from (select * from versions, bug_categories) as v
			 left outer join
			 			(select f.version_name, b.standardized_name, count(b.report_id)
										from standard_bugs b
										join files f on f.file_id=b.file_id
										group by f.version_name, b.standardized_name) as b
						on v.version_name=b.version_name and v.standardized_name=b.standardized_name
			 order by v.standardized_name, v.release_date;

-- drop view rate_per_ver_dir_cat_s cascade;
create or replace view rate_per_ver_dir_cat_s as
select b.version_name,
			 b.release_date,
			 b.study_dirname,
			 b.standardized_name,
			 b.number_of_bugs,
			 n.count number_of_notes,
			 round(100*coalesce(b.number_of_bugs, 0)::numeric/coalesce(n.count, coalesce(b.number_of_bugs, 1)), 2) as rate_in_percentage
			 from bugs_per_ver_dir_cat_s b
			 left outer join
			 			(select f.version_name, fn.study_dirname, n.standardized_name, count(n.note_id)
										from standard_notes n
										join files f on n.file_id=f.file_id
										join file_names fn on f.file_name=fn.file_name
										group by f.version_name, fn.study_dirname, n.standardized_name) as n
						on b.version_name=n.version_name and b.study_dirname=n.study_dirname and b.standardized_name=n.standardized_name
			 order by b.release_date, b.study_dirname, b.standardized_name;

-- drop view rate_per_ver_cat_s cascade;
create or replace view rate_per_ver_cat_s as
select b.standardized_name,
			 b.version_name,
			 b.release_date,
			 b.number_of_bugs,
			 n.count as number_of_notes,
			 round(100*coalesce(b.number_of_bugs, 0)::numeric/coalesce(n.count, coalesce(b.number_of_bugs, 1)), 2) as rate_in_percentage
			 from bugs_per_ver_cat_s b
			 left outer join
			 			(select f.version_name, n.standardized_name, count(n.note_id)
										from standard_notes n
										join files f on n.file_id=f.file_id
										group by f.version_name, n.standardized_name) as n
						on b.version_name=n.version_name and b.standardized_name=n.standardized_name
			 order by b.standardized_name, b.release_date;

-- drop view rate_per_files cascade;
create or replace view rate_per_files as
select v.version_name,
			 v.release_date,
			 f.file_id,
			 b.count as number_of_bugs,
			 n.count as number_of_notes,
			 round(100*coalesce(b.count, 0)::numeric/coalesce(n.count, 1), 2) as rate_in_percentage
			 from files f
			 join versions v on v.version_name=f.version_name
			 left outer join
			 			(select b.file_id, count(b.report_id)
										from standard_bugs b
										where has_notes(b.standardized_name)
										group by b.file_id) as b on b.file_id=f.file_id
			 left outer join (select n.file_id, count(n.note_id) from standard_notes n group by n.file_id) as n on n.file_id=f.file_id
			 order by v.release_date desc;

-- drop view bugs_intro_elim_per_ver_cat_s cascade;
create or replace view bugs_intro_elim_per_ver_cat_s as
select v.version_name,
			 v.release_date,
			 v.standardized_name,
			 coalesce(b.number_of_new_bugs, 0) as number_of_new_bugs,
			 coalesce(d.number_of_removed_bugs, 0) as number_of_removed_bugs
			 from (select * from versions, bug_categories) as v
			 left outer join
			 			(select c.standardized_name, c.correlation_birth_version as version_name,
										count(c.correlation_id) as number_of_new_bugs
										from full_bug_correlations c
										group by c.standardized_name, c.correlation_birth_version) as b
						on b.version_name=v.version_name and b.standardized_name=v.standardized_name
			 left outer join
			 			(select c.standardized_name, c.correlation_death_version as version_name,
										count(c.correlation_id) as number_of_removed_bugs
										from full_bug_correlations c
										group by c.standardized_name, c.correlation_death_version) as d
						on d.version_name=v.version_name and d.standardized_name=v.standardized_name
			 order by v.standardized_name, v.release_date;

--
-- Construct the relative rates
--
-- drop view relative_rate_per_ver_dir_cat_s cascade;
create or replace view relative_rate_per_ver_dir_cat_s as
select r.version_name,
			 r.release_date,
			 r.study_dirname,
			 r.standardized_name,
			 round((coalesce(r.number_of_bugs, 0)::numeric*coalesce(sum(o.number_of_notes), coalesce(sum(o.number_of_bugs), 0))::numeric)
							/(r.number_of_notes::numeric*coalesce(sum(o.number_of_bugs), sum(o.number_of_bugs))::numeric), 2)
							as relative_rate_in_percentage
			 from rate_per_ver_dir_cat_s r
			 join rate_per_ver_dir_cat_s o
			 			on  o.version_name=r.version_name
						and o.standardized_name=r.standardized_name
						and o.study_dirname!=r.study_dirname
			 where has_notes(r.standardized_name)
			 group by r.version_name, r.release_date, r.study_dirname, r.standardized_name, r.number_of_bugs, r.number_of_notes
			 order by r.release_date, r.study_dirname, r.standardized_name;

--------------------------------------------
--             check views                --
--------------------------------------------
--
-- gives the reports that have no associated notes
--
-- drop view orphan_reports_without_notes cascade;
create or replace view orphan_reports_without_notes as
select r.standardized_name,
			 r.report_error_name,
			 r.report_id,
			 r.file_id,
       f.version_name,
       f.file_name,
       r.line_no,
       r.column_start,
       r.status
			 from standard_reports r
 			 left outer join standard_notes n
			 			on r.file_id = n.file_id
				and r.line_no = n.line_no
				and (n.standardized_name='Block'
		   			or n.standardized_name='Lock'
 	   						  or n.standardized_name='LockIntr'
 	   						  or r.column_start = n.column_start)
				and r.standardized_name = n.standardized_name
			 join files f on r.file_id=f.file_id
			 where has_notes(r.standardized_name)
			   and n.note_id is null;

CREATE OR REPLACE VIEW study_bugs_and_reports_number AS
    SELECT r.release_date,
	r.version_name,
	r.status,
	r.number_of_reports,
	s.total_in_version
	FROM (SELECT r.release_date,
		r.version_name,
		r.status,
		count(*) AS number_of_reports
		FROM full_reports r
		WHERE ((r.standardized_name)::text <> 'Real'::text)
		GROUP BY r.version_name, r.status, r.release_date
		ORDER BY r.version_name, r.status) r
	JOIN (SELECT r.version_name, count(*) AS total_in_version
		FROM full_reports r
		WHERE ((r.standardized_name)::text <> 'Real'::text)
		GROUP BY r.version_name) s
	USING (version_name)
	ORDER BY r.release_date;

