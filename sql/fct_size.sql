-- Rely on study_rate_version(), do_lin_bucket() and do_log_bucket()

--
-- Helper view lin/log independent
--

CREATE OR REPLACE VIEW study_rate_per_function_restrict_s AS
SELECT v.version_name,
       v.release_date,
       func.function_id,
       b.count AS number_of_bugs,
       n.count AS number_of_notes,
       round(100::numeric * COALESCE(b.count, 0::bigint)::numeric / COALESCE(n.count, 1::bigint)::numeric, 2) AS rate_in_percentage
   FROM functions func
   JOIN files f ON f.file_id = func.file_id
   JOIN versions v ON v.version_name::text = f.version_name::text AND v.version_name::text = study_rate_version()::text
   LEFT JOIN ( SELECT func.function_id, count(b.report_id) AS count
   FROM "Faults info" b
   JOIN functions func ON b.file_id = func.file_id AND b.line_no >= func.start AND b.line_no <= func.finish
  WHERE has_notes(b.standardized_name::text)
  GROUP BY func.function_id) b ON b.function_id = func.function_id
   LEFT JOIN ( SELECT func.function_id, count(n.note_id) AS count
   FROM "Notes info" n
   JOIN functions func ON n.file_id = func.file_id AND n.line_no >= func.start AND n.line_no <= func.finish
  GROUP BY func.function_id) n ON n.function_id = func.function_id
  WHERE n.count IS NOT NULL
  ORDER BY v.release_date DESC;

--
-- Views for linear buckets
--

-- Helpers study_rate_per_function_restrict_s, study_linear_bucket_fct_lgth
CREATE OR REPLACE VIEW study_linear_bucket_fct_lgth AS
 SELECT DISTINCT v.version_name,
v.release_date,
func.function_id,
func.file_id,
func.function_name,
func.start,
func.finish,
func.length,
do_lin_bucket(row_number() OVER (PARTITION BY f.version_name ORDER BY func.length), study_nb_buckets(), t.number_of_functions) AS bucket
   FROM ( SELECT count(fooo.function_id) AS number_of_functions
           FROM ( SELECT func.function_id
                   FROM functions func
		   JOIN "Notes info" n
		   	ON n.file_id = func.file_id AND n.line_no >= func.start AND n.line_no <= func.finish AND n.version_name::text = study_rate_version()::text
             GROUP BY func.function_id) fooo) t, ( SELECT DISTINCT func.function_id, func.file_id, func.function_name, func.start, func.finish, func.finish - func.start + 1 AS length
           FROM functions func
      JOIN "Notes info" n ON n.file_id = func.file_id AND n.line_no >= func.start AND n.line_no <= func.finish AND n.version_name::text = study_rate_version()::text) func
   JOIN files f ON func.file_id = f.file_id
   JOIN versions v ON f.version_name::text = v.version_name::text AND v.version_name::text = study_rate_version()::text
  ORDER BY v.release_date, do_lin_bucket(row_number() OVER (PARTITION BY f.version_name ORDER BY func.length), study_nb_buckets(), t.number_of_functions), func.length;

-- Main view
CREATE OR REPLACE VIEW study_rate_per_fct_size_linear_buckets AS
SELECT b.version_name, b.release_date, b.bucket, t.average_fct_size, t.min_fct_size, t.max_fct_size, t.nb_fncs_per_bucket, round(100::numeric * b.number_of_bugs / b.number_of_notes, 2) AS rate_in_percentage, b.number_of_bugs, b.number_of_notes
   FROM ( SELECT b.version_name, b.release_date, b.bucket, sum(r.number_of_bugs) AS number_of_bugs, sum(r.number_of_notes) AS number_of_notes
           FROM study_rate_per_function_restrict_s r
      JOIN study_linear_bucket_fct_lgth b ON r.function_id = b.function_id
     GROUP BY b.version_name, b.release_date, b.bucket) b
   JOIN ( SELECT b.version_name, b.bucket, round(avg(b.length), 2) AS average_fct_size, min(b.length) AS min_fct_size, max(b.length) AS max_fct_size, count(b.file_id) AS nb_fncs_per_bucket
           FROM study_linear_bucket_fct_lgth b
          GROUP BY b.version_name, b.bucket
          ORDER BY b.version_name) t ON b.bucket = t.bucket AND b.version_name::text = t.version_name::text
  ORDER BY b.release_date, b.bucket;

--
-- Views for logarithmic buckets
--
CREATE OR REPLACE VIEW study_log_bucket_function_by_length_restrict_s_noted_fcts AS
 SELECT DISTINCT v.version_name,
v.release_date,
func.function_id,
func.file_id,
func.function_name,
func.start,
func.finish,
func.length,
do_exp_bucket(row_number() OVER (PARTITION BY f.version_name ORDER BY func.length), study_nb_buckets(), t.number_of_functions) AS bucket
   FROM ( SELECT count(fooo.function_id) AS number_of_functions
           FROM ( SELECT func.function_id
                   FROM functions func
		   JOIN "Notes info" n
		   	ON n.file_id = func.file_id
			AND n.line_no >= func.start
			AND n.line_no <= func.finish
			AND n.version_name::text = study_rate_version()::text
             GROUP BY func.function_id) fooo) t, (
	     	   SELECT DISTINCT func.function_id, func.file_id, func.function_name, func.start, func.finish, func.finish - func.start + 1 AS length
           	   FROM functions func
      		   JOIN "Notes info" n
		   ON n.file_id = func.file_id
		   AND n.line_no >= func.start AND n.line_no <= func.finish AND n.version_name::text = study_rate_version()::text) func
   		   JOIN files f ON func.file_id = f.file_id
   		   JOIN versions v ON f.version_name::text = v.version_name::text AND v.version_name::text = study_rate_version()::text
  		   ORDER BY v.release_date,
		   do_exp_bucket(row_number() OVER (PARTITION BY f.version_name ORDER BY func.length), study_nb_buckets(), t.number_of_functions),
		   func.length;

CREATE OR REPLACE VIEW study_log_bucket_function_by_length_restrict_s_all_fcts AS
SELECT v.version_name,
v.release_date,
func.function_id,
func.file_id,
func.function_name,
func.start,
func.finish,
func.length,
do_exp_bucket(row_number() OVER (PARTITION BY f.version_name ORDER BY func.length), study_nb_buckets(), t.number_of_functions) AS bucket
   FROM ( SELECT func.function_id, func.file_id, func.function_name, func.start, func.finish, func.finish - func.start + 1 AS length
           FROM functions func) func
   JOIN files f ON func.file_id = f.file_id
   JOIN versions v ON f.version_name::text = v.version_name::text AND v.version_name::text = study_rate_version()::text
   JOIN ( SELECT v.version_name, count(func.function_id) AS number_of_functions
   FROM versions v
   JOIN files f ON f.version_name::text = v.version_name::text
   JOIN functions func ON f.file_id = func.file_id
  GROUP BY v.version_name) t ON t.version_name::text = v.version_name::text
  ORDER BY v.release_date, do_exp_bucket(row_number() OVER (PARTITION BY f.version_name ORDER BY func.length), study_nb_buckets(), t.number_of_functions), func.length;

CREATE OR REPLACE VIEW study_rate_per_fct_size_restrict_s_noted_fcts AS
SELECT b.version_name,
b.release_date,
b.bucket,
t.average_fct_size,
t.min_fct_size,
t.max_fct_size,
t.nb_fncs_per_bucket,
round(100::numeric * b.number_of_bugs / b.number_of_notes, 2) AS rate_in_percentage,
b.number_of_bugs,
b.number_of_notes
FROM (
     SELECT b.version_name, b.release_date, b.bucket, sum(r.number_of_bugs) AS number_of_bugs, sum(r.number_of_notes) AS number_of_notes
     FROM study_rate_per_function_restrict_s r
JOIN study_log_bucket_function_by_length_restrict_s_noted_fcts b ON r.function_id = b.function_id
GROUP BY b.version_name, b.release_date, b.bucket) b
JOIN ( SELECT b.version_name, b.bucket, round(avg(b.length), 2) AS average_fct_size, min(b.length) AS min_fct_size, max(b.length) AS max_fct_size, count(b.file_id) AS nb_fncs_per_bucket
     FROM study_log_bucket_function_by_length_restrict_s_noted_fcts b
     GROUP BY b.version_name, b.bucket
ORDER BY b.version_name) t ON b.bucket = t.bucket AND b.version_name::text = t.version_name::text
ORDER BY b.release_date, b.bucket;

CREATE OR REPLACE VIEW study_rate_per_fct_size_restrict_s_all_fcts AS
SELECT b.version_name,
b.release_date,
b.bucket,
t.average_fct_size,
t.min_fct_size,
t.max_fct_size,
t.nb_fncs_per_bucket,
round(100::numeric * b.number_of_bugs / b.number_of_notes, 2) AS rate_in_percentage,
b.number_of_bugs,
b.number_of_notes
FROM (
     SELECT b.version_name, b.release_date, b.bucket, sum(r.number_of_bugs) AS number_of_bugs, sum(r.number_of_notes) AS number_of_notes
     FROM study_rate_per_function_restrict_s r
JOIN study_log_bucket_function_by_length_restrict_s b ON r.function_id = b.function_id

GROUP BY b.version_name, b.release_date, b.bucket) b
JOIN ( SELECT b.version_name, b.bucket, round(avg(b.length), 2) AS average_fct_size, min(b.length) AS min_fct_size, max(b.length) AS max_fct_size, count(b.file_id) AS nb_fncs_per_bucket
     FROM study_log_bucket_function_by_length_restrict_s b
     GROUP BY b.version_name, b.bucket
ORDER BY b.version_name) t ON b.bucket = t.bucket AND b.version_name::text = t.version_name::text
ORDER BY b.release_date, b.bucket;