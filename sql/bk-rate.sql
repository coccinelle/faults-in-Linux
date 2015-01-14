
--DROP VIEW public.study_rate_by_age;
CREATE OR REPLACE VIEW study_rate_by_age AS
    SELECT b.bucket, r.standardized_name, a.average_age, a.min_age, a.max_age, a.nb_files_per_bucket, (((100)::numeric * sum(r.number_of_reports)) / sum(r.number_of_notes)) AS rate, sum(r.number_of_reports) AS number_of_reports, sum(r.number_of_notes) AS number_of_notes FROM (SELECT f.file_id, study_do_bucket(row_number() OVER (ORDER BY fa.file_age_in_years), study_nb_buckets(), t.tot) AS bucket FROM files f, file_ages fa, (SELECT count(*) AS tot FROM file_ages WHERE ((file_ages.version_name)::text = (study_rate_version())::text)) t WHERE ((((f.version_name)::text = (study_rate_version())::text) AND ((fa.file_name)::text = (f.file_name)::text)) AND ((fa.version_name)::text = (f.version_name)::text))) b, (SELECT b.bucket, avg(b.file_age_in_years) AS average_age, min(b.file_age_in_years) AS min_age, max(b.file_age_in_years) AS max_age, count(b.file_id) AS nb_files_per_bucket FROM (SELECT f.file_id, fa.file_age_in_years, study_do_bucket(row_number() OVER (ORDER BY fa.file_age_in_years), study_nb_buckets(), t.tot) AS bucket FROM files f, file_ages fa, (SELECT count(*) AS tot FROM file_ages WHERE ((file_ages.version_name)::text = (study_rate_version())::text)) t WHERE ((((f.version_name)::text = (study_rate_version())::text) AND ((fa.file_name)::text = (f.file_name)::text)) AND ((fa.version_name)::text = (f.version_name)::text))) b GROUP BY b.bucket) a, rates r WHERE ((b.file_id = r.file_id) AND (a.bucket = b.bucket)) GROUP BY b.bucket, r.standardized_name, a.average_age, a.min_age, a.max_age, a.nb_files_per_bucket ORDER BY r.standardized_name, b.bucket;

--DROP VIEW public.study_rate_by_fct_size;
CREATE OR REPLACE VIEW study_rate_by_fct_size AS
    SELECT b.bucket, r.standardized_name, a.average_length AS average_fct_size, a.min_length AS min_fct_size, a.max_length AS max_fct_size, a.nb_functions_per_bucket, (((100)::numeric * sum(r.number_of_reports)) / sum(r.number_of_notes)) AS rate, sum(r.number_of_reports) AS number_of_reports, sum(r.number_of_notes) AS number_of_notes FROM (SELECT func.function_id, func.file_id, func.function_name, func.start, func.finish, func.len, study_do_bucket(row_number() OVER (ORDER BY func.len), study_nb_buckets(), t.tot) AS bucket FROM (SELECT functions.function_id, functions.file_id, functions.function_name, functions.start, functions.finish, (functions.finish - functions.start) AS len FROM functions) func, files f, (SELECT count(*) AS tot FROM functions func, files f WHERE (((f.version_name)::text = (study_rate_version())::text) AND (func.file_id = f.file_id))) t WHERE (((f.version_name)::text = (study_rate_version())::text) AND (f.file_id = func.file_id))) b, (SELECT b.bucket, avg(b.len) AS average_length, min(b.len) AS min_length, max(b.len) AS max_length, count(b.function_id) AS nb_functions_per_bucket FROM (SELECT func.function_id, func.file_id, func.function_name, func.start, func.finish, func.len, study_do_bucket(row_number() OVER (ORDER BY func.len), study_nb_buckets(), t.tot) AS bucket FROM (SELECT functions.function_id, functions.file_id, functions.function_name, functions.start, functions.finish, (functions.finish - functions.start) AS len FROM functions) func, files f, (SELECT count(*) AS tot FROM functions func, files f WHERE (((f.version_name)::text = (study_rate_version())::text) AND (func.file_id = f.file_id))) t WHERE (((f.version_name)::text = (study_rate_version())::text) AND (f.file_id = func.file_id))) b GROUP BY b.bucket) a, (SELECT n.function_id, n.standardized_name, COALESCE(r.number_of_reports, (0)::bigint) AS number_of_reports, n.number_of_notes FROM ((SELECT func.function_id, r.standardized_name, count(*) AS number_of_reports FROM report_with_notes r, functions func, files f WHERE (((((r.file_id = func.file_id) AND (f.file_id = r.file_id)) AND ((f.version_name)::text = (study_rate_version())::text)) AND ((r.line_no >= func.start) AND (r.line_no <= func.finish))) AND ((r.status)::text = 'BUG'::text)) GROUP BY func.function_id, r.standardized_name) r RIGHT JOIN (SELECT func.function_id, n.standardized_name, count(*) AS number_of_notes FROM standardized_notes n, functions func, files f WHERE ((((n.file_id = func.file_id) AND (f.file_id = n.file_id)) AND ((f.version_name)::text = (study_rate_version())::text)) AND ((n.line_no >= func.start) AND (n.line_no <= func.finish))) GROUP BY func.function_id, n.standardized_name) n ON ((((n.function_id = r.function_id) AND ((n.standardized_name)::text = (r.standardized_name)::text)) AND useful_for_rates((n.standardized_name)::text))))) r WHERE ((a.bucket = b.bucket) AND (b.function_id = r.function_id)) GROUP BY b.bucket, r.standardized_name, a.average_length, a.min_length, a.max_length, a.nb_functions_per_bucket ORDER BY r.standardized_name, b.bucket;

--
--
--
-- DROP VIEW study_total_rate_by_churn;
CREATE OR REPLACE VIEW study_total_rate_by_churn AS
    SELECT study_rate_by_churn.bucket, study_rate_by_churn.average_churn, study_rate_by_churn.min_churn, study_rate_by_churn.max_churn, study_rate_by_churn.nb_files_per_bucket, (((100)::numeric * sum(study_rate_by_churn.number_of_reports)) / sum(study_rate_by_churn.number_of_notes)) AS rate, sum(study_rate_by_churn.number_of_reports) AS number_of_reports, sum(study_rate_by_churn.number_of_notes) AS number_of_notes FROM study_rate_by_churn GROUP BY study_rate_by_churn.bucket, study_rate_by_churn.average_churn, study_rate_by_churn.min_churn, study_rate_by_churn.max_churn, study_rate_by_churn.nb_files_per_bucket ORDER BY study_rate_by_churn.bucket;

--
-- Fig 21 a.
--
-- DROP VIEW study_total_rate_by_age;
CREATE VIEW study_total_rate_by_age AS
SELECT study_rate_by_age.bucket,
       study_rate_by_age.average_age,
       study_rate_by_age.min_age,
       study_rate_by_age.max_age,
       study_rate_by_age.nb_files_per_bucket,
       100::numeric * sum(study_rate_by_age.number_of_reports) / sum(study_rate_by_age.number_of_notes) AS rate,
       sum(study_rate_by_age.number_of_reports) AS number_of_reports,
       sum(study_rate_by_age.number_of_notes) AS number_of_notes
FROM study_rate_by_age
  GROUP BY study_rate_by_age.bucket,
  study_rate_by_age.average_age,
  study_rate_by_age.min_age,
  study_rate_by_age.max_age,
  study_rate_by_age.nb_files_per_bucket
  ORDER BY study_rate_by_age.bucket;

--
-- Fig 21 b.
--
-- DROP VIEW study_total_rate_by_fct_size;
CREATE OR REPLACE VIEW study_total_rate_by_fct_size AS
    SELECT study_rate_by_fct_size.bucket, study_rate_by_fct_size.average_fct_size, study_rate_by_fct_size.min_fct_size, study_rate_by_fct_size.max_fct_size, study_rate_by_fct_size.nb_functions_per_bucket, (((100)::numeric * sum(study_rate_by_fct_size.number_of_reports)) / sum(study_rate_by_fct_size.number_of_notes)) AS rate, sum(study_rate_by_fct_size.number_of_reports) AS number_of_reports, sum(study_rate_by_fct_size.number_of_notes) AS number_of_notes FROM study_rate_by_fct_size GROUP BY study_rate_by_fct_size.bucket, study_rate_by_fct_size.average_fct_size, study_rate_by_fct_size.min_fct_size, study_rate_by_fct_size.max_fct_size, study_rate_by_fct_size.nb_functions_per_bucket ORDER BY study_rate_by_fct_size.bucket;
