select *
from authors a
     right outer join history h
     on a.author_id = h.author_id 
     or a.author_id = h.committer_id
where h.commit_id = null;