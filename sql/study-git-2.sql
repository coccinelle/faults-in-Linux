-- create table tmp_git_expertises_of_bugs(
-- correlation_id      int		primary key,
-- commit_id           VarChar(64) references history,
-- author_id           int         not null references authors,
-- author_expertise    real,
-- committer_id        int         not null references authors(author_id),
-- committer_expertise real
-- );


-- Give the bug author distribution according to their expertise

select round(author_expertise::numeric,2) as exp_centile, count(correlation_id)
from tmp_git_expertises_of_bugs
group by exp_centile
order by exp_centile;

-- Give the avg bug author expertise per centile
-- 2356 bugs in total
-- Each decile represents 230/240 bugs
-- Each centile represents 23/24 bugs

select ntile, avg(author_expertise) * 100
from (select ntile(10) over (order by author_expertise), correlation_id
     from tmp_git_expertises_of_bugs) as d
join tmp_git_expertises_of_bugs tmp
on tmp.correlation_id = d.correlation_id
group by ntile
order by ntile;

-- Give the bug committer distribution according to their expertise

select round(committer_expertise::numeric,2) as exp_centile, count(correlation_id)
from tmp_git_expertises_of_bugs
group by exp_centile
order by exp_centile;

-- Expertise evolution of bug authors

select correlation_birth_date as date, avg(author_expertise),
stddev_samp(author_expertise),
stddev_pop(author_expertise)
from full_bug_correlations
join tmp_git_expertises_of_bugs using (correlation_id)
group by correlation_birth_date
order by correlation_birth_date;

-- 

-----------------------------------------
-----------------------------------------
-----------------------------------------
select exp_centile, sum(count)
from (select ntile(100) over (order by author_expertise) as exp_centile, count(correlation_id)
     from tmp_git_expertises_of_bugs group by author_expertise) as exp_centile
group by exp_centile
order by exp_centile;

select ntile(100) over () as exp_centile, count(correlation_id)
from tmp_git_expertises_of_bugs;

select ntile(100) over (order by author_expertise), correlation_id from tmp_git_expertises_of_bugs;

-- Is there a correlation between the expertise of an author and its committer ?
--
-- select corr(author_expertise, committer_expertise) from tmp_git_expertises_of_bugs ;
--        corr        
-- -------------------
--  0.132944328605546
