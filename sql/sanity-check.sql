select *
from authors a
     right outer join history h
     on a.author_id = h.author_id 
     or a.author_id = h.committer_id
where h.commit_id = null;

select * from versions order by release_date desc limit 1;

select version_name, count(file_id) as number_of_files
from full_files
where version_main = 3
group by version_name, release_date
order by release_date;

select version_name, count(function_id) as number_of_functions
from functions, full_files
where version_main = 3
and functions.file_id = full_files.file_id
group by version_name, release_date
order by release_date;

select version_name, count(note_id) as number_of_notes
from full_notes
where version_main = 3
group by version_name, release_date
order by release_date
