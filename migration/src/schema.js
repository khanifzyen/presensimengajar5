const schema = [
    {
        name: 'users',
        type: 'auth',
        schema: [
            {
                name: 'role',
                type: 'select',
                required: true,
                options: {
                    maxSelect: 1,
                    values: ['admin', 'teacher']
                }
            },
            {
                name: 'verified',
                type: 'bool',
                required: false
            }
        ]
    },
    {
        name: 'subjects',
        type: 'base',
        schema: [
            {
                name: 'name',
                type: 'text',
                required: true,
                unique: true
            },
            {
                name: 'code',
                type: 'text',
                required: false,
                unique: true
            },
            {
                name: 'description',
                type: 'text',
                required: false
            }
        ]
    },
    {
        name: 'teachers',
        type: 'base',
        schema: [
            {
                name: 'user_id',
                type: 'relation',
                required: true,
                unique: true,
                options: {
                    collectionId: 'users',
                    cascadeDelete: true,
                    maxSelect: 1
                }
            },
            {
                name: 'nip',
                type: 'text',
                required: true,
                unique: true
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
                options: {
                    maxSelect: 1,
                    maxSize: 5242880,
                    mimeTypes: ['image/jpeg', 'image/png', 'image/svg+xml', 'image/gif', 'image/webp']
                }
            },
            {
                name: 'subject_id',
                type: 'relation',
                required: false,
                options: {
                    collectionId: 'subjects',
                    cascadeDelete: false,
                    maxSelect: 1
                }
            },
            {
                name: 'position',
                type: 'select',
                required: false,
                options: {
                    maxSelect: 1,
                    values: ['guru', 'kepala_sekolah', 'wakil_kepala', 'staff_tu']
                }
            },
            {
                name: 'attendance_category',
                type: 'select',
                required: true,
                options: {
                    maxSelect: 1,
                    values: ['tetap', 'jadwal']
                }
            },
            {
                name: 'status',
                type: 'select',
                required: true,
                options: {
                    maxSelect: 1,
                    values: ['active', 'inactive']
                }
            },
            {
                name: 'join_date',
                type: 'date',
                required: false
            }
        ]
    },
    {
        name: 'classes',
        type: 'base',
        schema: [
            {
                name: 'name',
                type: 'text',
                required: true,
                unique: true
            },
            {
                name: 'level',
                type: 'select',
                required: false,
                options: {
                    maxSelect: 1,
                    values: ['X', 'XI', 'XII']
                }
            },
            {
                name: 'major',
                type: 'select',
                required: false,
                options: {
                    maxSelect: 1,
                    values: ['IPA', 'IPS', 'Umum']
                }
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
        ]
    },
    {
        name: 'academic_periods',
        type: 'base',
        schema: [
            {
                name: 'name',
                type: 'text',
                required: true,
                unique: true
            },
            {
                name: 'semester',
                type: 'select',
                required: true,
                options: {
                    maxSelect: 1,
                    values: ['ganjil', 'genap']
                }
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
        ]
    },
    {
        name: 'schedules',
        type: 'base',
        schema: [
            {
                name: 'teacher_id',
                type: 'relation',
                required: true,
                options: {
                    collectionId: 'teachers',
                    cascadeDelete: true,
                    maxSelect: 1
                }
            },
            {
                name: 'subject_id',
                type: 'relation',
                required: true,
                options: {
                    collectionId: 'subjects',
                    cascadeDelete: false,
                    maxSelect: 1
                }
            },
            {
                name: 'class_id',
                type: 'relation',
                required: true,
                options: {
                    collectionId: 'classes',
                    cascadeDelete: false,
                    maxSelect: 1
                }
            },
            {
                name: 'period_id',
                type: 'relation',
                required: true,
                options: {
                    collectionId: 'academic_periods',
                    cascadeDelete: false,
                    maxSelect: 1
                }
            },
            {
                name: 'day',
                type: 'select',
                required: true,
                options: {
                    maxSelect: 1,
                    values: ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu']
                }
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
        ]
    },
    {
        name: 'attendances',
        type: 'base',
        schema: [
            {
                name: 'teacher_id',
                type: 'relation',
                required: true,
                options: {
                    collectionId: 'teachers',
                    cascadeDelete: true,
                    maxSelect: 1
                }
            },
            {
                name: 'schedule_id',
                type: 'relation',
                required: false,
                options: {
                    collectionId: 'schedules',
                    cascadeDelete: false,
                    maxSelect: 1
                }
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
                options: {
                    maxSelect: 1,
                    values: ['office', 'class']
                }
            },
            {
                name: 'check_in',
                type: 'date', // PocketBase uses date type for datetime as well
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
                options: {
                    maxSelect: 1,
                    values: ['hadir', 'telat', 'izin', 'sakit', 'alpha']
                }
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
                options: {
                    maxSelect: 1,
                    maxSize: 5242880,
                    mimeTypes: ['image/jpeg', 'image/png', 'image/webp']
                }
            },
            {
                name: 'notes',
                type: 'text',
                required: false
            }
        ]
    },
    {
        name: 'leave_requests',
        type: 'base',
        schema: [
            {
                name: 'teacher_id',
                type: 'relation',
                required: true,
                options: {
                    collectionId: 'teachers',
                    cascadeDelete: true,
                    maxSelect: 1
                }
            },
            {
                name: 'type',
                type: 'select',
                required: true,
                options: {
                    maxSelect: 1,
                    values: ['sakit', 'cuti', 'dinas']
                }
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
                options: {
                    maxSelect: 1,
                    maxSize: 5242880,
                    mimeTypes: ['application/pdf', 'image/jpeg', 'image/png']
                }
            },
            {
                name: 'status',
                type: 'select',
                required: true,
                options: {
                    maxSelect: 1,
                    values: ['pending', 'approved', 'rejected']
                }
            },
            {
                name: 'approved_by',
                type: 'relation',
                required: false,
                options: {
                    collectionId: 'users',
                    cascadeDelete: false,
                    maxSelect: 1
                }
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
        ]
    },
    {
        name: 'settings',
        type: 'base',
        schema: [
            {
                name: 'key',
                type: 'text',
                required: true,
                unique: true
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
                options: {
                    maxSelect: 1,
                    values: ['text', 'number', 'boolean', 'json']
                }
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
                options: {
                    maxSelect: 1,
                    values: ['general', 'location', 'time', 'notification']
                }
            }
        ]
    },
    {
        name: 'notifications',
        type: 'base',
        schema: [
            {
                name: 'user_id',
                type: 'relation',
                required: true,
                options: {
                    collectionId: 'users',
                    cascadeDelete: true,
                    maxSelect: 1
                }
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
                options: {
                    maxSelect: 1,
                    values: ['info', 'success', 'warning', 'error']
                }
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
        ]
    }
];

module.exports = schema;
