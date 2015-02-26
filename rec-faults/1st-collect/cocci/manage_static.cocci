virtual check_for_static, external

@initialize:python@
@@

import os

started = False # not super elegant, but useful for making local initializers

def output_external(ex,fn,tmp,file,version,extra_opts):
  options="--dir /fast_scratch/linuxes/%s --no-includes --use-glimpse --very-quiet --timeout 60 --allow-inconsistent-paths" % (version)
#  cache="--cache-prefix /fast_scratch/linuxes/cocci.cache/ --cache-limit 100"
  cache=""
  defns="-D alloc=%s -D file=%s -D tmp=%s -D version=%s %s" % (fn,file,tmp,version,extra_opts)
  call="spatch.opt --cocci-file cocci/%s.cocci %s %s %s > %s" % (ex,defns,options, cache,tmp)
  print "%s ; cat %s >> %s" % (call,tmp,file)


def output_static(ex,fn,tmp,file,version,extra_opts,cfile):
  options="%s --no-includes --very-quiet --timeout 60 --allow-inconsistent-paths" % (cfile)
#  cache="--cache-prefix /fast_scratch/linuxes/cocci.cache/ --cache-limit 100"
  cache=""
  defns="-D alloc=%s -D file=%s -D tmp=%s -D version=%s %s" % (fn,file,tmp,version,extra_opts)
  call="spatch.opt --cocci-file cocci/%s.cocci %s %s %s > %s" % (ex,defns,options,cache,tmp)
  print "%s ; cat %s >> %s" % (call,tmp,file)
