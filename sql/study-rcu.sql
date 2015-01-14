--
-- fig 22 -- reuse study_fig_notes_in_26

--
-- fig 23
--
-- drop view study_fig_bugs_rcu_per_ver_cat_in_26 cascade;
create or replace view study_fig_bugs_rcu_per_ver_cat_in_26 as
select standardized_name, version_name, release_date, coalesce(number_of_bugs, 0)
from bugs_per_ver_cat_s
where linux_ge(version_name, 'linux-2.6.0')
and is_rcu(standardized_name);

-- drop view study_fig_rate_rcu_by_ver_cat_26 cascade;
create or replace view study_fig_rate_rcu_by_ver_cat_26 as
select standardized_name, version_name, release_date, rate_in_percentage
from rate_per_ver_cat_s
where linux_ge(version_name, 'linux-2.6.0')
and is_rcu(standardized_name)
and has_notes(standardized_name);

--
-- fig 24
--
-- drop view study_fig_faults_rcu_by_ver_dir_26 cascade;
create or replace view study_fig_faults_rcu_by_ver_dir_26 as
-- select study_dirname, version_name, release_date, coalesce(sum(number_of_bugs), 0) as number_of_bugs -- gives 0 when there is no data
select study_dirname, version_name, release_date, sum(number_of_bugs) as number_of_bugs -- gives NULL when there is no data (cut curve, ie for staging)
from bugs_per_ver_dir_cat_s
where linux_ge(version_name, 'linux-2.6.0')
and is_rcu(standardized_name)
and number_of_bugs >= 0 -- to use with null value
group by study_dirname, version_name, release_date
order by study_dirname, release_date;
