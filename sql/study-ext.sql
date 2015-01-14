-- DROP VIEW report_with_notes;
CREATE OR REPLACE VIEW report_with_notes AS
    SELECT r.report_id,
    r.file_id,
    r.standardized_name,
    r.status,
    r.line_no
    FROM full_reports r, full_notes n
    WHERE (((((r.file_id = n.file_id) AND (r.line_no = n.line_no))
    AND (((((r.standardized_name)::text = 'Block'::text) OR ((r.standardized_name)::text = 'Lock'::text)) OR ((r.standardized_name)::text = 'LockIntr'::text))
    OR (r.column_start = n.column_start)))
    AND ((r.standardized_name)::text = (n.standardized_name)::text))
    AND useful_for_rates((n.standardized_name)::text));

--
-- fig 19
--
-- DROP VIEW faults_per_churn;
CREATE OR REPLACE VIEW faults_per_churn AS
SELECT b.correlation_birth_version, b.correlation_birth_date,
       count(b.correlation_id) AS nb_faults, m.nb_mods,
       count(b.correlation_id)::double precision / a.release_length::double precision AS norm_faults,
       m.nb_mods::double precision / a.release_length::double precision AS norm_mods,
       100::double precision * count(b.correlation_id)::double precision / m.nb_mods::double precision AS rate_pct
   FROM full_correlations b, full_versions a, ( SELECT files.version_name, sum(files.nb_mods) AS nb_mods
           FROM files
          GROUP BY files.version_name) m
  WHERE b.correlation_birth_version::text = m.version_name::text
  	AND b.correlation_birth_version::text = a.version_name::text
	AND b.status::text = 'BUG'::text
	AND b.correlation_birth_date > '2003-12-18'::date
-- Should we discard RCU and Block ?
  GROUP BY b.correlation_birth_version, b.correlation_birth_date, m.nb_mods, a.release_length
  ORDER BY b.correlation_birth_date;

--
-- fig 20
--
-- DROP VIEW rates;
CREATE OR REPLACE VIEW rates AS
    SELECT nnn.file_id,
    f.study_dirname,
    f.version_name,
    nnn.standardized_name,
    COALESCE(rrr.total, (0)::bigint) AS number_of_reports,
    nnn.total AS number_of_notes
    FROM full_files f,
    	 ((SELECT r.file_id, r.standardized_name, count(*) AS total
	 FROM report_with_notes r
	 WHERE ((r.status)::text = 'BUG'::text)
	 GROUP BY r.file_id, r.standardized_name) rrr
	 RIGHT JOIN (SELECT n.file_id, n.standardized_name, count(*) AS total
	       FROM full_notes n
	       GROUP BY n.file_id, n.standardized_name) nnn
	 ON (((((rrr.standardized_name)::text = (nnn.standardized_name)::text)
	 AND (rrr.file_id = nnn.file_id))
	 AND useful_for_rates((nnn.standardized_name)::text))))
    WHERE (nnn.file_id = f.file_id);

-- DROP VIEW study_rate_by_error_name_4_x386_allyes;
CREATE OR REPLACE VIEW study_rate_by_error_name_4_x386_allyes AS
    SELECT f.version_name,
           r.standardized_name,
	   f.allyes_compiled,
	   (((100)::numeric * sum(r.number_of_reports)) / sum(r.number_of_notes)) AS rate
    FROM files f, rates r
    WHERE ((r.file_id = f.file_id)
    AND ((f.file_name)::text ~~ '%.c'::text))
    GROUP BY f.version_name, r.standardized_name, f.allyes_compiled;
