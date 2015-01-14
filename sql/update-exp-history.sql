
update history set author_expertise = cdata.author_expertise,
committer_expertise = cdata.committer_expertise
from (select h.commit_id,
       get_author_expertise(h.author_id, h.author_date) as author_expertise,
       get_committer_expertise(h.committer_id, h.committer_date) as committer_expertise
from history h) cdata
where cdata.commit_id = history.commit_id;
