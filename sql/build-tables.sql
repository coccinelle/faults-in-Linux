CREATE LANGUAGE plpgsql;

-- Engler's names of bugs
CREATE TABLE bug_categories (
	standardized_name    VarChar(256),
	standardized_name_id integer,
	
	PRIMARY KEY(standardized_name, standardized_name_id)
);

-- binding of the errors between us and Engler's ones
CREATE TABLE error_names (
	report_error_name    VarChar(256) PRIMARY KEY,
	standardized_name    VarChar(256) NOT NULL REFERENCES bug_categories
);

-- binding of the notes between us and Engler's ones
CREATE TABLE note_names (
	note_error_name      VarChar(256) PRIMARY KEY,
	standardized_name    VarChar(256)  NOT NULL REFERENCES bug_categories
);

--
-- Name: dir_names; List of directories to study
--
CREATE TABLE study_dirnames (
       study_dirname    text PRIMARY KEY,
       study_dirname_id int  NOT NULL
);

-- versions are used to compute the age of a file and to filter versions
CREATE TABLE versions (
	version_name         VarChar(256) PRIMARY KEY, -- '2.6.33' for example
	commit_id            VarChar(256) ,            -- revision name
	main                 integer      NOT NULL,    -- 2
	major                integer      NOT NULL,    -- 6
	minor                integer,                  -- 33
	release_date	     date	  NOT NULL,    -- used to compute the age of a file
	locc		     bigint	  DEFAULT 0 NOT NULL,-- # of C-code lines

	unique (commit_id),
	unique (main, major, minor)
);

COMMENT ON COLUMN versions.commit_id IS 'Revision name in the source code manager';

-- Describe of a file
CREATE TABLE file_names (
	file_name            VarChar(256) PRIMARY KEY,
	family_name          VarChar(256) NOT NULL,    -- first part of the directory
	type_name            VarChar(256) NOT NULL,    -- second part
	impl_name	     VarChar(256) NOT NULL,    -- third part
	other_name	     VarChar(256) NOT NULL,     -- other parts
	study_dirname	     VarChar(256) NOT NULL     -- the study dir name
);

-- describe a file with version
CREATE TABLE files (
	file_id              serial       PRIMARY KEY,
	file_name            VarChar(256) NOT NULL REFERENCES file_names,
	version_name         VarChar(256) NOT NULL REFERENCES versions,
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
CREATE TABLE notes (
	note_id              serial       PRIMARY KEY,
	file_id              int          NOT NULL REFERENCES files,
	data_source          VarChar(256) NOT NULL, -- for update
	note_error_name      VarChar(256) NOT NULL,
	line_no              int          NOT NULL,
	column_start         int          NOT NULL,
	column_end           int          NOT NULL,
	text_link            VarChar(256) ,         -- text hyperlink

	UNIQUE (file_id, note_error_name, line_no, column_start, column_end)
);
CREATE UNIQUE INDEX note_idx ON notes (file_id, note_error_name, line_no, column_start, column_end);

CREATE TABLE authors (
       author_id            serial         PRIMARY KEY,
       author_name          VarChar(256)   UNIQUE NOT NULL
);

-- create table tmp_bug_authors (
-- correlation_id       int            primary key references correlations,
-- author_id            int            not null references authors,
-- commit_id            VarChar(64)    not null
-- );

CREATE TABLE history (
commit_id            VarChar(64)    PRIMARY KEY,
author_id            int            NOT NULL REFERENCES authors,
author_date          date           NOT NULL,
committer_id         int            NOT NULL REFERENCES authors(author_id),
committer_date       date           NOT NULL,
version_name         VarChar(256)   REFERENCES versions ON UPDATE CASCADE ON DELETE SET NULL,
author_expertise     real,
committer_expertise  real
);

-- TODO: Add a reference (fkey) to the versions table once the history table is created.

CREATE SEQUENCE correlation_idx;

-- describe a set of correlated reports
CREATE TABLE correlations (
	correlation_id       int            PRIMARY KEY,
	report_error_name    VarChar(256)   NOT NULL,
	status               VarChar(256)   NOT NULL,
	reason_phrase        VarChar(256),           -- annotation
	data_source          VarChar(256)   NOT NULL,
	birth_commit_number  VarChar(64),            -- hash of the commit that introduces the bug
	death_commit_number  VarChar(64),            -- hash of the commit that removes the bug
	patch_status	     VarChar(128)	     -- status of the fix.
);

-- describe one report
CREATE TABLE reports (
	report_id            serial       PRIMARY KEY,
	correlation_id       int          NOT NULL REFERENCES correlations ON DELETE CASCADE,
	file_id              int          NOT NULL REFERENCES files ON DELETE CASCADE,
	line_no              int          NOT NULL,
	column_start         int          NOT NULL,
	column_end           int          NOT NULL,
	text_link            VarChar(256) ,         -- text hyperlink

	UNIQUE (report_id, file_id, line_no, column_start, column_end)
);
CREATE UNIQUE INDEX reports_idx ON reports (correlation_id, file_id, line_no, column_start, column_end);
CREATE INDEX correlation_fkey ON reports USING hash (correlation_id);
CREATE INDEX fault_position ON reports USING btree (file_id, line_no, column_start, column_end);
CREATE UNIQUE INDEX reports_pkey ON reports USING btree (report_id);

-- describe a position of a note
-- create table report_annotations (
-- 	report_id            int          not null references reports on delete cascade,
-- 	line_no              int          not null,
-- 	column_start         int          not null,
-- 	column_end           int          not null,
-- 	text_link            VarChar(256)            -- text hyperlink
-- );

-- describe a function
CREATE TABLE functions (
	function_id         serial       PRIMARY KEY,
	file_id             int          NOT NULL REFERENCES files ON DELETE CASCADE,
	function_name       VarChar(256) NOT NULL,
	start               int          NOT NULL,
	finish              int          NOT NULL,

	UNIQUE(file_id, start),
	UNIQUE(file_id, finish)
);
