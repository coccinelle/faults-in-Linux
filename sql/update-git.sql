drop table tmp_git_expertises_of_bugs;

create table tmp_git_expertises_of_bugs(
correlation_id      int		primary key,
commit_id           VarChar(64) references history,
author_id           int         not null references authors,
author_expertise    real,
committer_id        int         not null references authors(author_id),
committer_expertise real
);

insert into tmp_git_expertises_of_bugs
select correlation_id,
       commit_id,
       author_id,
       author_expertise,
       committer_id,
       committer_expertise
from git_expertises_of_bugs;

-- UPDATE correlations c
-- SET author_id = h.author_id
-- FROM history h
-- WHERE c.birth_commit_number = h.commit_id;

-- UPDATE history h
-- SET author_id = a2.author_id
-- FROM authors a, authors a2
-- WHERE a.author_name = 'cxie4'
-- AND a.author_id = h.author_id
-- AND a2.author_name = 'Chao Xie';
