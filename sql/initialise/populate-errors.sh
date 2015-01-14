#!/bin/sh

cat > /tmp/ORGFILES24 <<EOF
#Linux-2.4_block1a.new.org
#Linux-2.4_block1b.new.org
#Linux-2.4_bad_lock3.new.org
#Linux-2.4_bad_lock4.new.org
#Linux-2.4_block1c.new.org
#Linux-2.4_bad_lock5.new.org
#Mini-osdi_bad_null2.new.org
#Linux-2.4_var.new.org
#Linux-2.4_isnull5.new.org
#Linux-2.4_null_ref6.new.org
#Linux-2.4_get.new.org
#Linux-2.4_copy.new.org
#Linux-2.4_lock.new.org
#Linux-2.4_double_lock2.new.org
#Linux-2.4_intr.new.org
#Linux-2.4_intr_noarg_cli_sti.new.org
#Linux-2.4_intr_noarg_local_irq_enable_disable.new.org
#Linux-2.4_lockintr.new.org
#Linux-2.4_double_lockintr2.new.org
#Linux-2.4_kfree.new.org
#Linux-2.4_bad_kfree.new.org
#Linux-2.4_floatop.new.org
#Linux-2.4_realloc.new.org
#Linux-2.4_noderef.new.org
#Linux-2.4_size_rule.new.org
EOF

cat > /tmp/ORGFILES26 <<EOF
#Linux-2.6_block1a.new.org
#Linux-2.6_block1b.new.org
#Linux-2.6_bad_lock3.new.org
#Linux-2.6_bad_lock4.new.org
#Linux-2.6_block1c.new.org
#Linux-2.6_bad_lock5.new.org
#Linux-2.6_bad_null3.new.org
#Linux-2.6_var.new.org
#Linux-2.6_isnull5.new.org
#Linux-2.6_null_ref6.new.org
#Linux-2.6_get.new.org
#Linux-2.6_copy.new.org
#Linux-2.6_lock.new.org
#Linux-2.6_double_lock2.new.org
#Linux-2.6_intr.new.org
#Linux-2.6_intr_noarg_cli_sti.new.org
#Linux-2.6_intr_noarg_local_irq_enable_disable.new.org
#Linux-2.6_lockintr.new.org
#Linux-2.6_double_lockintr2.new.org
#Linux-2.6_kfree.new.org
#Linux-2.6_bad_kfree.new.org
#Linux-2.6_floatop.new.org
#Linux-2.6_realloc.new.org
#Linux-2.6_noderef.new.org
#Linux-2.6_size_rule.new.org
#Linux-2.6_srcu_lock.new.org
#Linux-2.6_rcu_lock.new.org
#Linux-2.6_rcu_lock_bh.new.org
#Linux-2.6_rcu_lock_sched.new.org
#Linux-2.6_rcu_lock_sched_notrace.new.org
#Linux-2.6_bad_rcu.new.org
#Linux-2.6_rcu_deref_out.new.org
EOF

ORGDIR=../../engler/results/linuxes
CWD=`pwd`
LOGFILE=$CWD/`basename $0 .sh`.log

if [ "$1" == "reset" ]; then
	echo "SELECT setval('correlation_idx', 1, false);" | psql linuxbugs -e -q -o /dev/null
	echo "SELECT setval('reports_report_id_seq', 1, false);" | psql linuxbugs -e -q -o /dev/null

# Truncating the table correlations will also truncate the tables reports and report_annotations.
	echo "TRUNCATE correlations CASCADE;" | psql linuxbugs -e -q -o /dev/null ;
fi

cd $ORGDIR

> $LOGFILE
for f in `grep -v "^#" /tmp/ORGFILES24`; do
    echo "Processing $f"
    echo "*** Processing $f ***" >> $LOGFILE
    FILTERED=Linux241-$f
    herodotos.opt --parse_org $f --extract linux-2.4.1 \
	--prefix /var/linuxes/ > $FILTERED
    herodotos.opt --parse_org $FILTERED --to-sql \
	--prefix /var/linuxes/ | psql linuxbugs -e -q 2>&1 | tee >> $LOGFILE
done

for f in `grep -v "^#" /tmp/ORGFILES26`; do
    echo "Processing $f"
    echo "*** Processing $f ***" >> $LOGFILE
    FILTERED=$f
    #FILTERED=Linux-no34-$f
    #grep -v "linux-2\.6\.34" $f > $FILTERED
    herodotos.opt --parse_org $FILTERED --to-sql \
	--prefix /var/linuxes/ | psql linuxbugs -e -q 2>&1 | tee >> $LOGFILE
    #rm -f $FILTERED
done
cd - 2>&1 > /dev/null

# Linux-1.x_block.new.org
# Linux-1.x_copy_deref.new.org
# Linux-1.x_copy.new.org
# Linux-1.x_double_lockintr.new.org
# Linux-1.x_double_lock.new.org
# Linux-1.x_float.new.org
# Linux-1.x_floatop.new.org
# Linux-1.x_get.new.org
# Linux-1.x_intr.new.org
# Linux-1.x_intr_noarg_cli_sti.new.org
# Linux-1.x_intr_noarg_local_irq_enable_disable.new.org
# Linux-1.x_isnull.new.org
# Linux-1.x_kfree.new.org
# Linux-1.x_lockintr.new.org
# Linux-1.x_lock.new.org
# Linux-1.x_noderef.new.org
# Linux-1.x_null_ref.new.org
# Linux-1.x_realloc.new.org
# Linux-1.x_size_rule.new.org
# Linux-1.x_var.new.org

# Linux-2.0_block.new.org
# Linux-2.0_copy_deref.new.org
# Linux-2.0_copy.new.org
# Linux-2.0_double_lockintr.new.org
# Linux-2.0_double_lock.new.org
# Linux-2.0_float.new.org
# Linux-2.0_floatop.new.org
# Linux-2.0_get.new.org
# Linux-2.0_intr.new.org
# Linux-2.0_intr_noarg_cli_sti.new.org
# Linux-2.0_intr_noarg_local_irq_enable_disable.new.org
# Linux-2.0_isnull.new.org
# Linux-2.0_kfree.new.org
# Linux-2.0_lockintr.new.org
# Linux-2.0_lock.new.org
# Linux-2.0_noderef.new.org
# Linux-2.0_null_ref.new.org
# Linux-2.0_realloc.new.org
# Linux-2.0_size_rule.new.org
# Linux-2.0_var.new.org

# Linux-2.1_block.new.org
# Linux-2.1_copy_deref.new.org
# Linux-2.1_copy.new.org
# Linux-2.1_double_lockintr.new.org
# Linux-2.1_double_lock.new.org
# Linux-2.1_float.new.org
# Linux-2.1_floatop.new.org
# Linux-2.1_get.new.org
# Linux-2.1_intr.new.org
# Linux-2.1_intr_noarg_cli_sti.new.org
# Linux-2.1_intr_noarg_local_irq_enable_disable.new.org
# Linux-2.1_isnull.new.org
# Linux-2.1_kfree.new.org
# Linux-2.1_lockintr.new.org
# Linux-2.1_lock.new.org
# Linux-2.1_noderef.new.org
# Linux-2.1_null_ref.new.org
# Linux-2.1_realloc.new.org
# Linux-2.1_size_rule.new.org
# Linux-2.1_var.new.org

# Linux-2.2_block.new.org
# Linux-2.2_copy_deref.new.org
# Linux-2.2_copy.new.org
# Linux-2.2_double_lockintr.new.org
# Linux-2.2_double_lock.new.org
# Linux-2.2_float.new.org
# Linux-2.2_floatop.new.org
# Linux-2.2_get.new.org
# Linux-2.2_intr.new.org
# Linux-2.2_intr_noarg_cli_sti.new.org
# Linux-2.2_intr_noarg_local_irq_enable_disable.new.org
# Linux-2.2_isnull.new.org
# Linux-2.2_kfree.new.org
# Linux-2.2_lockintr.new.org
# Linux-2.2_lock.new.org
# Linux-2.2_noderef.new.org
# Linux-2.2_null_ref.new.org
# Linux-2.2_realloc.new.org
# Linux-2.2_size_rule.new.org
# Linux-2.2_var.new.org

# Linux-2.3_block.new.org
# Linux-2.3_copy_deref.new.org
# Linux-2.3_copy.new.org
# Linux-2.3_double_lockintr.new.org
# Linux-2.3_double_lock.new.org
# Linux-2.3_float.new.org
# Linux-2.3_floatop.new.org
# Linux-2.3_get.new.org
# Linux-2.3_intr.new.org
# Linux-2.3_intr_noarg_cli_sti.new.org
# Linux-2.3_intr_noarg_local_irq_enable_disable.new.org
# Linux-2.3_isnull.new.org
# Linux-2.3_kfree.new.org
# Linux-2.3_lockintr.new.org
# Linux-2.3_lock.new.org
# Linux-2.3_noderef.new.org
# Linux-2.3_notes_noderef.new.org
# Linux-2.3_null_ref.new.org
# Linux-2.3_realloc.new.org
# Linux-2.3_size_rule.new.org
# Linux-2.3_var.new.org

# Linux-2.5_block.new.org
# Linux-2.5_copy_deref.new.org
# Linux-2.5_copy.new.org
# Linux-2.5_double_lockintr.new.org
# Linux-2.5_double_lock.new.org
# Linux-2.5_float.new.org
# Linux-2.5_floatop.new.org
# Linux-2.5_get.new.org
# Linux-2.5_intr.new.org
# Linux-2.5_intr_noarg_cli_sti.new.org
# Linux-2.5_intr_noarg_local_irq_enable_disable.new.org
# Linux-2.5_isnull.new.org
# Linux-2.5_kfree.new.org
# Linux-2.5_lockintr.new.org
# Linux-2.5_lock.new.org
# Linux-2.5_noderef.new.org
# Linux-2.5_null_ref.new.org
# Linux-2.5_realloc.new.org
# Linux-2.5_size_rule.new.org
# Linux-2.5_var.new.org
