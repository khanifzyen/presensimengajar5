const schema = [
    {
        name: 'users',
        type: 'auth',
        fields: [
            {
                name: 'role',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['admin', 'teacher']
            },
            {
                name: 'verified',
                type: 'bool',
                required: false
            }
        ],
        indexes: []
    },
    {
        name: 'subjects',
        type: 'base',
        fields: [
            {
                name: 'name',
                type: 'text',
                required: true
            },
            {
                name: 'code',
                type: 'text',
                required: false
            },
            {
                name: 'description',
                type: 'text',
                required: false
            }
        ],
        indexes: [
            'CREATE UNIQUE INDEX `idx_subjects_name` ON `subjects` (`name`)',
            'CREATE UNIQUE INDEX `idx_subjects_code` ON `subjects` (`code`)'
        ]
    },
    {
        name: 'teachers',
        type: 'base',
        fields: [
            {
                name: 'user_id',
                type: 'relation',
                required: true,
                collectionId: 'users',
                cascadeDelete: true,
                maxSelect: 1
            },
            {
                name: 'nip',
                type: 'text',
                required: true
            },
            {
                name: 'name',
                type: 'text',
                required: true
            },
            {
                name: 'phone',
                type: 'text',
                required: false
            },
            {
                name: 'address',
                type: 'text',
                required: false
            },
            {
                name: 'photo',
                type: 'file',
                required: false,
                maxSelect: 1,
                maxSize: 5242880,
                mimeTypes: ['image/jpeg', 'image/png', 'image/svg+xml', 'image/gif', 'image/webp']
            },
            {
                name: 'subject_id',
                type: 'relation',
                required: false,
                collectionId: 'subjects',
                cascadeDelete: false,
                maxSelect: 1
            },
            {
                name: 'position',
                type: 'select',
                required: false,
                maxSelect: 1,
                values: ['guru', 'kepala_sekolah', 'wakil_kepala', 'staff_tu']
            },
            {
                name: 'attendance_category',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['tetap', 'jadwal']
            },
            {
                name: 'status',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['active', 'inactive']
            },
            {
                name: 'join_date',
                type: 'date',
                required: false
            }
        ],
        indexes: [
            'CREATE UNIQUE INDEX `idx_teachers_user_id` ON `teachers` (`user_id`)',
            'CREATE UNIQUE INDEX `idx_teachers_nip` ON `teachers` (`nip`)'
        ]
    },
    {
        name: 'classes',
        type: 'base',
        fields: [
            {
                name: 'name',
                type: 'text',
                required: true
            },
            {
                name: 'level',
                type: 'select',
                required: false,
                maxSelect: 1,
                values: ['X', 'XI', 'XII']
            },
            {
                name: 'major',
                type: 'select',
                required: false,
                maxSelect: 1,
                values: ['IPA', 'IPS', 'Umum']
            },
            {
                name: 'room',
                type: 'text',
                required: false
            },
            {
                name: 'capacity',
                type: 'number',
                required: false
            }
        ],
        indexes: [
            'CREATE UNIQUE INDEX `idx_classes_name` ON `classes` (`name`)'
        ]
    },
    {
        name: 'academic_periods',
        type: 'base',
        fields: [
            {
                name: 'name',
                type: 'text',
                required: true
            },
            {
                name: 'semester',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['ganjil', 'genap']
            },
            {
                name: 'start_date',
                type: 'date',
                required: true
            },
            {
                name: 'end_date',
                type: 'date',
                required: true
            },
            {
                name: 'is_active',
                type: 'bool',
                required: false
            }
        ],
        indexes: [
            'CREATE UNIQUE INDEX `idx_academic_periods_name` ON `academic_periods` (`name`)'
        ]
    },
    {
        name: 'schedules',
        type: 'base',
        fields: [
            {
                name: 'teacher_id',
                type: 'relation',
                required: true,
                collectionId: 'teachers',
                cascadeDelete: true,
                maxSelect: 1
            },
            {
                name: 'subject_id',
                type: 'relation',
                required: true,
                collectionId: 'subjects',
                cascadeDelete: false,
                maxSelect: 1
            },
            {
                name: 'class_id',
                type: 'relation',
                required: true,
                collectionId: 'classes',
                cascadeDelete: false,
                maxSelect: 1
            },
            {
                name: 'period_id',
                type: 'relation',
                required: true,
                collectionId: 'academic_periods',
                cascadeDelete: false,
                maxSelect: 1
            },
            {
                name: 'day',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu']
            },
            {
                name: 'start_time',
                type: 'text',
                required: true
            },
            {
                name: 'end_time',
                type: 'text',
                required: true
            },
            {
                name: 'room',
                type: 'text',
                required: false
            }
        ],
        indexes: []
    },
    {
        name: 'attendances',
        type: 'base',
        fields: [
            {
                name: 'teacher_id',
                type: 'relation',
                required: true,
                collectionId: 'teachers',
                cascadeDelete: true,
                maxSelect: 1
            },
            {
                name: 'schedule_id',
                type: 'relation',
                required: false,
                collectionId: 'schedules',
                cascadeDelete: false,
                maxSelect: 1
            },
            {
                name: 'date',
                type: 'date',
                required: true
            },
            {
                name: 'type',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['office', 'class']
            },
            {
                name: 'check_in',
                type: 'date',
                required: false
            },
            {
                name: 'check_out',
                type: 'date',
                required: false
            },
            {
                name: 'status',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['hadir', 'telat', 'izin', 'sakit', 'alpha']
            },
            {
                name: 'latitude',
                type: 'number',
                required: false
            },
            {
                name: 'longitude',
                type: 'number',
                required: false
            },
            {
                name: 'location_address',
                type: 'text',
                required: false
            },
            {
                name: 'photo',
                type: 'file',
                required: false,
                maxSelect: 1,
                maxSize: 5242880,
                mimeTypes: ['image/jpeg', 'image/png', 'image/webp']
            },
            {
                name: 'notes',
                type: 'text',
                required: false
            }
        ],
        indexes: []
    },
    {
        name: 'leave_requests',
        type: 'base',
        fields: [
            {
                name: 'teacher_id',
                type: 'relation',
                required: true,
                collectionId: 'teachers',
                cascadeDelete: true,
                maxSelect: 1
            },
            {
                name: 'type',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['sakit', 'cuti', 'dinas']
            },
            {
                name: 'start_date',
                type: 'date',
                required: true
            },
            {
                name: 'end_date',
                type: 'date',
                required: true
            },
            {
                name: 'reason',
                type: 'text',
                required: true
            },
            {
                name: 'attachment',
                type: 'file',
                required: false,
                maxSelect: 1,
                maxSize: 5242880,
                mimeTypes: ['application/pdf', 'image/jpeg', 'image/png']
            },
            {
                name: 'status',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['pending', 'approved', 'rejected']
            },
            {
                name: 'approved_by',
                type: 'relation',
                required: false,
                collectionId: 'users',
                cascadeDelete: false,
                maxSelect: 1
            },
            {
                name: 'approved_at',
                type: 'date',
                required: false
            },
            {
                name: 'rejection_reason',
                type: 'text',
                required: false
            }
        ],
        indexes: []
    },
    {
        name: 'settings',
        type: 'base',
        fields: [
            {
                name: 'key',
                type: 'text',
                required: true
            },
            {
                name: 'value',
                type: 'text',
                required: false
            },
            {
                name: 'type',
                type: 'select',
                required: false,
                maxSelect: 1,
                values: ['text', 'number', 'boolean', 'json']
            },
            {
                name: 'description',
                type: 'text',
                required: false
            },
            {
                name: 'category',
                type: 'select',
                required: false,
                maxSelect: 1,
                values: ['general', 'location', 'time', 'notification']
            }
        ],
        indexes: [
            'CREATE UNIQUE INDEX `idx_settings_key` ON `settings` (`key`)'
        ]
    },
    {
        name: 'notifications',
        type: 'base',
        fields: [
            {
                name: 'user_id',
                type: 'relation',
                required: true,
                collectionId: 'users',
                cascadeDelete: true,
                maxSelect: 1
            },
            {
                name: 'title',
                type: 'text',
                required: true
            },
            {
                name: 'message',
                type: 'text',
                required: true
            },
            {
                name: 'type',
                type: 'select',
                required: false,
                maxSelect: 1,
                values: ['info', 'success', 'warning', 'error']
            },
            {
                name: 'is_read',
                type: 'bool',
                required: false
            },
            {
                name: 'data',
                type: 'json',
                required: false
            }
        ],
        indexes: []
    }
];

module.exports = schema;
