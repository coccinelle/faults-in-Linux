select b.study_dirname, t.ver_name, count(b.correlation_id) as number_of_correlations
			 from full_bug_correlations b
			 join (values
						  ('linux-2.4.1', 'linux-2.4.1',  'linux-24'),
						  ('linux-2.6.0', 'linux-2.6.39', 'linux-26')) as t(ver_min, ver_max, ver_name)
					on not linux_lt(b.correlation_last_version, t.ver_min) and not linux_gt(b.correlation_birth_version, t.ver_max)
		   group by b.study_dirname, t.ver_name
			 order by b.study_dirname, t.ver_name;

select b.study_dirname, 'x86', count(b.correlation_id) as number_of_correlations
			 from full_bug_correlations b
			 join (values
						  ('linux-2.4.1', 'linux-2.4.1',  'linux-24'),
						  ('linux-2.6.0', 'linux-2.6.39', 'linux-26')) as t(ver_min, ver_max, ver_name)
					on not linux_lt(b.correlation_last_version, t.ver_min) and not linux_gt(b.correlation_birth_version, t.ver_max)
			 where b.type_name='x86' or b.type_name='i386'
		   group by b.study_dirname, t.ver_name
			 order by b.study_dirname, t.ver_name;
