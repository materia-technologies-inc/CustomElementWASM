/**
 * @license
 * Copyright 2024-2025 Materia Technologies, Inc.
 *
 * SPDX-License-Identifier: SEE LICENSE IN License.md
 */

import { defineConfig } from 'vite'

// https://vitejs.dev/config/

/*

└── CustomeElementWSM/                   ← Solution root
    ├── Docsite.Vite/          ← Server root
    └── CustomElementWASM/     ← Custom element source
       
In fs: { allow: ['..'] },
  the '..' allows access to Content (sibling to Docsite.Vite)

*/

export default defineConfig({
    base: '/',
    build: { outDir: '.distribution' },
    root: 'Docsite.Vite',
    server: {
        fs: { allow: ['..'] }, // Allow access to Content sibling directory
        host: '0.0.0.0',
        port: 7304,
        strictPort: true,
    },
});
