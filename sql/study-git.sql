--  select current_timestamp, max(a.expertise) as author_max, max(c.expertise) as committer_max from git_rank_authors a, git_rank_committers c;
--               now              | author_max | committer_max 
-- -------------------------------+------------+---------------
--  2013-10-02 14:31:23.224383+02 |   33284862 |     156072000

create or replace function max_author_expertise() returns real
    LANGUAGE sql IMMUTABLE
    AS $$select cast(33284862 as real)$$;

create or replace function max_committer_expertise() returns real
    LANGUAGE sql IMMUTABLE
    AS $$select cast(156072000 as real)$$;

create or replace function get_author_expertise(int, date) returns real as $$
declare
	author_id_p ALIAS FOR $1;
        ref_date    ALIAS FOR $2;
        res               real;
begin
	select (max(author_date) - min(author_date)) * count(commit_id)::real / max_author_expertise() into res
	from history
	where history.author_id = author_id_p
	and author_date <= ref_date;
	return res;
 end;
$$ LANGUAGE 'plpgsql';

create or replace function get_committer_expertise(int, date) returns real as $$
declare
	committer_id_p ALIAS FOR $1;
        ref_date       ALIAS FOR $2;
        res                  real;
begin
	select (max(committer_date) - min(committer_date)) * count(commit_id)::real / max_committer_expertise() into res
	from history h
	where h.committer_id = committer_id_p
	and h.committer_date <= ref_date;
	return res;
 end;
$$ LANGUAGE 'plpgsql';

create or replace function get_committer_Xexpertise(int, date) returns real as $$
declare
	committer_id_p ALIAS FOR $1;
        ref_date       ALIAS FOR $2;
        res                  real;
begin
	select (max(committer_date) - min(committer_date)) * count(commit_id)::real / max_committer_expertise() into res
	from history h
	where (h.author_id = committer_id_p
 	   and h.author_date <= ref_date)
	or (h.committer_id = committer_id_p
	   and h.committer_date <= ref_date);
	return res;
 end;
$$ LANGUAGE 'plpgsql';

create or replace view git_rank_authors as
select history.author_id,
       author_name,
       count(commit_id),
       min(author_date) as first_commit,
       max(author_date) as last_commit,
       max(author_date) - min(author_date) as commitment,
       (max(author_date) - min(author_date)) * count(commit_id) as expertise
from history
join authors
on history.author_id = authors.author_id
group by history.author_id, author_name
order by count desc;

create or replace view git_rank_committers as
select committer_id,
       author_name as committer_name,
       count(commit_id),
       min(committer_date) as first_commit,
       max(committer_date) as last_commit,
       max(committer_date) - min(committer_date) as commitment,
       (max(committer_date) - min(committer_date)) * count(commit_id) as expertise
from history
join authors
on history.committer_id = authors.author_id
group by committer_id, author_name
order by count desc;

create or replace view git_expertises_of_bugs as
select fbc.correlation_id,
       h.commit_id,
       h.author_id,
       get_author_expertise(h.author_id, h.author_date) as author_expertise,
       h.committer_id,
       get_committer_expertise(h.committer_id, h.committer_date) as committer_expertise
from correlations fbc
join history h on fbc.birth_commit_number = h.commit_id
where fbc.status = 'BUG';
