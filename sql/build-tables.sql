create language plpgsql;

-- Engler's names of bugs
create table bug_categories (
	standardized_name    VarChar(256) not null ,
	standardized_name_id integer NOT NULL,
	
	primary key (standardized_name),
	unique (standardized_name_id)
);

-- binding of the errors between us and Engler's ones
create table error_names (
	report_error_name    VarChar(256) primary key,
	standardized_name    VarChar(256) not null -- references standardized_names
);

-- binding of the notes between us and Engler's ones
create table note_names (
	standardized_name    VarChar(256) not null, -- references standardized_names,
	note_error_name      VarChar(256) not null -- Can not be a primary key. Notes sharing.
);

--
-- Name: dir_names; List of directories to study
--
CREATE TABLE study_dirnames (
  study_dirname    text primary key,
	study_dirname_id int  NOT NULL
);

-- versions are used to compute the age of a file and to filter versions
create table versions (
	version_name         VarChar(256) primary key, -- '2.6.33' for example
	commit_id            VarChar(256) ,            -- revision name
	main                 integer      not null,    -- 2
	major                integer      not null,    -- 6
	minor                integer,                  -- 33
	release_date	     date	  not null,    -- used to compute the age of a file
	locc		     bigint	  DEFAULT 0 NOT NULL,-- # of C-code lines

	unique (commit_id),
	unique (main, major, minor)
);

COMMENT ON COLUMN versions.commit_id IS 'Revision name in the source code manager';

-- Describe of a file
create table file_names (
	file_name            VarChar(256) primary key,
	family_name          VarChar(256) not null,    -- first part of the directory
	type_name            VarChar(256) not null,    -- second part
	impl_name	     VarChar(256) not null,    -- third part
	other_name	     VarChar(256) not null,     -- other parts
	study_dirname	     VarChar(256) not null     -- the study dir name
);

-- describe a file with version
create table files (
	file_id              serial       primary key,
	file_name            VarChar(256) not null references file_names,
	version_name         VarChar(256) not null references versions,
	file_size            int	  ,
	nb_mods              int	  ,
	def_compiled	     boolean	  DEFAULT false NOT NULL,
	allyes_compiled	     boolean	  DEFAULT false NOT NULL,
	allmod_compiled	     boolean	  DEFAULT false NOT NULL,

	unique (file_name, version_name)
);

-- Store the list of files that are compiled by default
-- CREATE TABLE tmp_compile_x386 (
--	  	file_id		     int          NOT NULL,
-- 	version_name 	     VarChar(256) NOT NULL,
-- 	file_name 	     VarChar(256) NOT NULL,

-- 	unique (file_id),
-- 	unique (version_name),
-- 	unique (file_name)
-- );

-- describe a note
create table notes (
	note_id              serial       primary key,
	file_id              int          not null references files,
	data_source          VarChar(256) not null, -- for update
	note_error_name      VarChar(256) not null,
	line_no              int          not null,
	column_start         int          not null,
	column_end           int          not null,
	text_link            VarChar(256) ,         -- text hyperlink

	unique (file_id, note_error_name, line_no, column_start)
);

create table authors (
author_id            serial         primary key,
author_name          VarChar(256)   not null,

unique (author_name)
);

-- create table tmp_bug_authors (
-- correlation_id       int            primary key references correlations,
-- author_id            int            not null references authors,
-- commit_id            VarChar(64)    not null
-- );

create table history (
commit_id            VarChar(64)    primary key,
author_id            int            not null references authors,
author_date          date           not null,
committer_id         int            not null references authors(author_id),
committer_date       date           not null,
version_name         VarChar(256)   references versions ON UPDATE CASCADE ON DELETE SET NULL,
author_expertise     real,
committer_expertise  real
);

-- TODO: Add a reference (fkey) to the versions table once the history table is created.

create sequence correlation_idx;

-- describe a set of correlated reports
create table correlations (
	correlation_id       int            primary key,
	report_error_name    VarChar(256)   not null,
	status               VarChar(256)   not null,
	reason_phrase        VarChar(256),           -- annotation
	data_source          VarChar(256)   not null,
	birth_commit_number  VarChar(64),            -- hash of the commit that introduces the bug
	death_commit_number  VarChar(64),            -- hash of the commit that removes the bug
	patch_status	     VarChar(128)	     -- status of the fix.
);

-- describe one report
create table reports (
	report_id            serial       primary key,
	correlation_id       int          not null references correlations on delete cascade,
	file_id              int          not null references files on delete cascade,
	line_no              int          not null,
	column_start         int          not null,
	column_end           int          not null,
	text_link            VarChar(256) ,         -- text hyperlink

	unique (report_id, file_id, line_no, column_start)
);

-- describe a position of a note
-- create table report_annotations (
-- 	report_id            int          not null references reports on delete cascade,
-- 	line_no              int          not null,
-- 	column_start         int          not null,
-- 	column_end           int          not null,
-- 	text_link            VarChar(256)            -- text hyperlink
-- );

-- describe a function
create table functions (
	function_id         serial       primary key,
	file_id             int          not null references files on delete cascade,
	function_name       VarChar(256) not null,
	start               int          not null,
	finish              int          not null,

	unique(file_id, start),
	unique(file_id, finish)
);
