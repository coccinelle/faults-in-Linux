@initialize:python@
@@

import psycopg2
conn = psycopg2.connect("dbname=faults_in_Linux user=npalix")
curs = conn.cursor()

def add_note(ty,pos,src):
 for q in pos:
  file = "%s" % q.file
  line = "%s" % q.line
  colb = "%s" % q.column
  cole = "%s" % q.column_end
  front = file.partition("-")
  front = front[2].partition("/")
  version = front[0]
  file = front[2]
  str = "insert into notes (file_id,data_source,note_error_name,line_no,column_start,column_end,text_link) values (get_file('linux-%s','%s'),'%s','%s',%s,%s,%s,'%s')" % (version,file,src,ty,line,colb,cole,ty)

  print str + ";"
  try:
    curs.execute(str)
  except (psycopg2.InternalError,psycopg2.IntegrityError) as e:
    print e
  except:
    print "UNKNOWN ERROR"
  conn.commit()

@finalize:python@
@@
curs.close()
conn.close()
