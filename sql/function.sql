create or replace function get_file (text, text) returns int as $$
declare
	version_name_p ALIAS FOR $1;
	file_name_p    ALIAS FOR $2;
	res			     int;
begin
	select file_id into res from files f where f.file_name=file_name_p and f.version_name=version_name_p;

  return res;

end;
$$ LANGUAGE 'plpgsql';

-- line_no, column_start, column_end, text_link
create or replace function get_position (int, int, int, text) returns int as $$
declare
	line_no      ALIAS FOR $1;
	column_start ALIAS FOR $2;
	column_end   ALIAS FOR $3;
	text_link		 ALIAS FOR $4;
	res			     int;
begin
	select position_id into res from positions p
		where p.line_no=line_no
			and p.column_start=column_start
			and p.column_end=column_end
			and p.text_link=text_link;

  return res;

end;
$$ LANGUAGE 'plpgsql';

--
-- Name: compute_file_name_info(text): returns the different components of the path and the study_dirname as an array
--
create or replace function compute_file_name_info(text) returns text[5] as $$
			 select array[COALESCE(fn.t[1], ''), COALESCE(fn.t[2], ''), COALESCE(fn.t[3], ''), COALESCE(fn.t[4], ''),
							case
					 when fn.t[1] = 'arch'::text        then 'arch'::text
					 when fn.t[1] = 'net'::text         then 'net'::text
					 when fn.t[1] = 'fs'::text          then 'fs'::text
					 when fn.t[1] = 'sound'::text       then 'sound'::text
					 when fn.t[1] = 'drivers'::text     then
							case when fn.t[2] = 'staging' then 'staging'::text
					else 'drivers'::text
							end
					 else 'other'::text
							end]
							from (select fn.t[1:array_upper(fn.t, 1)-1] as t
 			  							 		 from (select regexp_split_to_array($1,'/') as t) as fn) as fn;
$$ LANGUAGE 'SQL';

--
-- Name: add_file_name(text): add a file_name in file_names if it is not yet present
--
create or replace function add_file_name(text) returns text as $$
begin
	if not exists (select * from file_names where file_name=$1) then
		 insert into file_names
		 select $1, t[1], t[2], t[3], t[4], t[5] from compute_file_name_info($1) as t;
  end if;
	return $1;
end;
$$ LANGUAGE 'plpgsql';

--
-- Name: rebuild_file_names(): rebuild all the file_names table without destroying anything
--
create or replace function rebuild_file_names() returns void as $$
begin
	update file_names f
			 set study_dirname=fn.t[5]
			 from
			 (select file_name, compute_file_name_info(file_name) as t from files group by file_name) as fn
			 where fn.file_name=f.file_name;
end;
$$ LANGUAGE 'plpgsql';

create or replace function do_exp_bucket(idx bigint, nb_buckets int, tot bigint) returns int as $$
declare
	i int;
	f int;
begin
	f := cast(tot/(power(2, nb_buckets) - 1) as integer);
	i=0;

	while i<nb_buckets loop
				if idx >= (tot - (f * (power(2, i+1)-1))) then
					 return nb_buckets - i - 1;
				end if;
				i=i+1;
	end loop;

	return 0;
end
$$ language 'plpgsql';

create or replace function do_lin_bucket(idx bigint, nb_buckets int, tot bigint) returns int as $$
declare
	r int;
begin
	r := cast((nb_buckets * idx) / tot as int);
	if r < nb_buckets then
		 return r;
	end if;
	return nb_buckets-1;
end
$$ language 'plpgsql';


--
--
-- drop function has_notes(standardized_name text) cascade;
create or replace function has_notes(standardized_name text) returns boolean
    LANGUAGE 'plpgsql' IMMUTABLE
    AS $$begin
	 return standardized_name!='Float' ; end;$$;

-- drop function is_rcu(standardized_name text) cascade;
create or replace function is_rcu(standardized_name text) returns boolean
    LANGUAGE 'plpgsql' IMMUTABLE
    AS $$begin
	 return standardized_name='BlockRCU'
	 		or  standardized_name='DerefRCU'
      or  standardized_name='LockRCU' ; end;$$;


-- drop function linux_gt(standardized_name text) cascade;
create or replace function linux_gt(n1 text, n2 text) returns boolean
    LANGUAGE 'plpgsql' IMMUTABLE
    AS $$begin return v1.release_date>v2.release_date from versions v1, versions v2 where v1.version_name=n1 and v2.version_name=n2; end;$$;

-- drop function linux_ge(standardized_name text) cascade;
create or replace function linux_ge(n1 text, n2 text) returns boolean
    LANGUAGE 'plpgsql' IMMUTABLE
    AS $$begin return v1.release_date>=v2.release_date from versions v1, versions v2 where v1.version_name=n1 and v2.version_name=n2; end;$$;

-- drop function linux_lt(standardized_name text) cascade;
create or replace function linux_lt(n1 text, n2 text) returns boolean
    LANGUAGE 'plpgsql' IMMUTABLE
    AS $$begin return v1.release_date<v2.release_date from versions v1, versions v2 where v1.version_name=n1 and v2.version_name=n2; end;$$;

-- drop function linux_le(standardized_name text) cascade;
create or replace function linux_le(n1 text, n2 text) returns boolean
    LANGUAGE 'plpgsql' IMMUTABLE
    AS $$begin return v1.release_date<=v2.release_date from versions v1, versions v2 where v1.version_name=n1 and v2.version_name=n2; end;$$;


create or replace function do_exp_bucket(idx bigint, nb_buckets int, tot bigint) returns int as $$
declare
	i int;
	f int;
begin
	f := cast(tot/(power(2, nb_buckets) - 1) as integer);
	i=0;

	while i<nb_buckets loop
				if idx >= (tot - (f * (power(2, i+1)-1))) then
					 return nb_buckets - i - 1;
				end if;
				i=i+1;
	end loop;

	return 0;
end
$$ language 'plpgsql';

create or replace function do_lin_bucket(idx bigint, nb_buckets int, tot bigint) returns int as $$
declare
	r int;
begin
	r := cast((nb_buckets * idx) / tot as int);
	if r < nb_buckets then
		 return r;
	end if;
	return nb_buckets-1;
end
$$ language 'plpgsql';


--
--
--
CREATE OR REPLACE FUNCTION useful_for_rates(text) RETURNS boolean
    LANGUAGE plpgsql
        AS $_$
	begin
		return $1!='Float';
		end;
		$_$;

create or replace function get_author_id (text) returns int as $$
declare
        name_p ALIAS FOR $1;
        res                          int;
begin
  if not exists (select * from authors where author_name=name_p) then
                 insert into authors (author_name) values (name_p);
  end if;
  select author_id into res from authors a where name_p = author_name;

  return res;

end;
$$ LANGUAGE 'plpgsql';

