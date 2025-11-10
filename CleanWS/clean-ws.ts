/**
 * @license
 * Copyright 2024-2025 Materia Technologies, Inc.
 *
 * SPDX-License-Identifier: SEE LICENSE IN License.md
 */

/**
 *  2024-??-??  Mark Stega
 *              Created
 * 
 *  2025-10-22  Mark Stega
 *              Updated for new directory structure (CMS.Vite, etc.)
 */

import * as fs from 'node:fs';

fs.rmSync('.artifacts', { recursive: true, force: true });
fs.rmSync('.wireit', { recursive: true, force: true });

fs.rmSync('CMS.Vite/public/_content', { recursive: true, force: true });
fs.rmSync('CMS.Vite/public/_framework', { recursive: true, force: true });
