
truncate study_dirnames cascade;
insert into study_dirnames (study_dirname, study_dirname_id) values
        ('sound',   0),
        ('drivers', 1),
        ('arch',    2),
        ('fs',      3),
        ('net',     4),
        ('staging', 5),
        ('other',   6);

truncate bug_categories cascade;
insert into bug_categories (standardized_name, standardized_name_id) values
			 ('BlockLock', 0),
			 ('BlockIntr', 1),
			 ('Null',      2),
			 ('Var',       3),
			 ('IsNull',    4),
			 ('NullRef',   5),
			 ('Range',     6),
			 ('Lock',      7),
			 ('Intr',      8),
			 ('LockIntr',  9),
			 ('Free',     10),
			 ('Float',    11),
--			 ('Real',     12),
			 ('Size',     13),
			 ('BlockRCU', 14),
			 ('LockRCU',  15),
			 ('DerefRCU', 16);

truncate error_names cascade;
insert into error_names (standardized_name, report_error_name) values
	('BlockLock', 'bad_lock3a'                           ),
	('BlockLock', 'bad_lock4a'			       ),
	('BlockLock', 'block1a'			       ),
	('BlockLock', 'block1b'			       ),
	('BlockIntr', 'bad_lock5a'			       ),
	('BlockIntr', 'block1c'			       ),
	('Null'	    , 'bad_null2'			       ),
	('Null'	    , 'bad_null3'			       ),
	('Var'	    , 'var'				       ),
	('IsNull'   , 'isnull5'			       ),
	('NullRef'  , 'null_ref6'			       ),
	('Range'    , 'copy'				       ),
	('Range'    , 'get'				       ),
	('Lock'	    , 'double_lock2'			       ),
	('Lock'	    , 'lock'				       ),
	('Intr'	    , 'intr'				       ),
	('Intr'	    , 'intr_noarg_cli_sti'		       ),
	('Intr'	    , 'intr_noarg_local_irq_enable_disable' ),
	('LockIntr' , 'double_lockintr2'		       ),
	('LockIntr' , 'lockintr'			       ),
	('Free'	    , 'bad_kfree'			       ),
	('Free'	    , 'kfree'			       ),
	('Float'    , 'floatop'			       ),
	('Real'	    , 'realloc'			       ),
	('Size'	    , 'noderef'			       ),
	('Size'	    , 'size_rule'                           ),
	('LockRCU'  , 'rcu_lock'			       ),
	('LockRCU'  , 'rcu_lock_bh'			       ),
	('LockRCU'  , 'rcu_lock_sched'			       ),
	('LockRCU'  , 'rcu_lock_sched_notrace'		       ),
	('LockRCU'  , 'srcu_lock'			       ),
	('BlockRCU' , 'bad_rcu'				       ),
	('DerefRCU' , 'rcu_deref_out'			       );


truncate note_names cascade;
-- Check for double_lock and double_lockintr
insert into note_names (standardized_name, note_error_name) values
	( 'BlockLock',  'block' ),
	( 'BlockLock',  'bad_lock_notes'),

	( 'BlockIntr',  'block' ),
	( 'BlockIntr',  'bad_lock_notes'),

	( 'Null',   'bad_null2_notes'),
	( 'Null',   'bad_null3_notes'),

	( 'Var',     'var' ),

	( 'IsNull',   'inull'),
	( 'NullRef',   'inull'),

	( 'Range',  'copy'),
	( 'Range',  'get'),

	( 'Lock',     'lock' ),

	( 'Intr',     'intr' ),

	( 'LockIntr', 'lockintr' ),

	( 'Free',     'kfree' ),
	( 'Free',     'bad_kfree_notes'),

--	( 'Float',    NULL),

	( 'Real',     'krealloc' ),

	( 'Size',     'noderef' ),

	( 'LockRCU',  'rcu_lock' ),

	( 'BlockRCU' ,  'block' ),
	( 'BlockRCU' ,  'bad_lock_notes'),

	( 'DerefRCU', 'rcu_deref_out')
;

