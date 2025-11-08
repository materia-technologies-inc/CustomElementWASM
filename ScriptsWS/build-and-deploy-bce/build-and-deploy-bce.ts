/**
 * @license
 * Copyright 2024-2025 Materia Technologies, Inc.
 *
 * SPDX-License-Identifier: MIT
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 *  2025-10-23  Mark Stega
 *              Created
 *              This script cleans previous outputs, publishes the Blazor Custom Elements,
 *              and copies the necessary files to the Vite project.
 *              It also copies dotnet.{version}.js to dotnet.js due to a bug in .NET RC1.
 *
 *  2025-11-08  Mark Stega
 *             Added workaround for .NET 10 RC2 bug by copying from an RC1 publish
 */

import { spawn } from 'node:child_process';
import process from "node:process";
import * as fs from 'node:fs';
import * as path from 'node:path';

const publishBase = path.join('.artifacts', 'publish', 'CMS.BlazorCustomElements', 'release');
const artifacts = ".artifacts";
const sourceContent = path.join(publishBase, 'wwwroot', '_content');
const sourceFramework = path.join(publishBase, 'wwwroot', '_framework');
const targetContent = path.join('CMS.Vite', 'public', '_content');
const targetFramework = path.join('CMS.Vite', 'public', '_framework');

console.log("=====================================");
console.log("Blazor Custom Element Deployment");
console.log("=====================================");
console.log("");

console.log("Step 1: Cleaning previous build artifacts and published content...");

if (fs.existsSync(artifacts)) {
    // We need a try/catch here because VisualStudio will create directories if running
    try {
        fs.rmSync(artifacts, { recursive: true, force: true });
    }
    catch { };
    console.log(`  Cleaned ${artifacts}`);
}

if (fs.existsSync(targetContent)) {
    fs.rmSync(targetContent, { recursive: true, force: true });
    console.log(`  Cleaned ${targetContent}`);
}

if (fs.existsSync(targetFramework)) {
    fs.rmSync(targetFramework, { recursive: true, force: true });
    console.log(`  Cleaned ${targetFramework}`);
}


console.log("");
console.log("Step 2: Publishing CMS.BlazorCustomElements (Release)...");
await runCommand("dotnet publish CMS.BlazorCustomElements/CMS.BlazorCustomElements.csproj -c Release");
console.log("  Publish completed");

console.log("");
console.log("Step 3: Copying published files to Vite public folder...");

// Verify publish output
if (!fs.existsSync(publishBase)) {
    console.error(`  Publish output not found at: ${publishBase}`);
    process.exit(1);
}

// Copy _framework directory
if (fs.existsSync(sourceFramework)) {
    copyDirectoryRecursive(sourceFramework, targetFramework);
    console.log("  Copied _framework to Vite");

} else {
    console.error("  Source _framework not found!");
    process.exit(1);
}

// Copy _content directory
if (fs.existsSync(sourceContent)) {
    copyDirectoryRecursive(sourceContent, targetContent);
    console.log("  Copied _content to Vite");
} else {
    console.error("  Source _content not found!");
    process.exit(1);
}

///////////////////////////////////////////////////////////////////
// Copy from an RC1 generated publish to get around a known RC2 bug
///////////////////////////////////////////////////////////////////
console.log("");
console.log("Step 3W: Copying published files from an RC1 build to Vite public folder to mitigate an RC2 build issue...");

const SourceContentRC1 = path.join('CMS.Vite', 'public', '_content.rc1');
const sourceFrameworkRC1 = path.join('CMS.Vite', 'public', '_framework.rc1');

// Copy _framework directory
if (fs.existsSync(sourceFrameworkRC1)) {
    copyDirectoryRecursive(sourceFrameworkRC1, targetFramework);
    console.log("  Copied _framework.RC1 to Vite");

} else {
    console.error("  Source _framework.RC1 not found!");
    process.exit(1);
}

// Copy _content directory
if (fs.existsSync(SourceContentRC1)) {
    copyDirectoryRecursive(SourceContentRC1, targetContent);
    console.log("  Copied _content.RC1 to Vite");
} else {
    console.error("  Source _content.RC1 not found!");
    process.exit(1);
}
///////////////////////////////////////////////////////////////////
// End RC2 workaround
///////////////////////////////////////////////////////////////////

console.log("");
console.log("Step 4: Update index.html to reference correct blazor.webassembly.nnnnn.js file...");
// .NET 10 finger-print feature
const blazorWebAssemblyVersioned = fs.readdirSync(targetFramework)
    .filter(file => {
        const match = /^blazor\.webassembly\.[a-z0-9]+\.js$/.test(file);
        const notNativeOrRuntime = !/native|runtime/.test(file);
        return match && notNativeOrRuntime;
    })[0];

if (blazorWebAssemblyVersioned) {
    // Read index.html
    const indexHtmlPath = path.join('CMS.Vite', 'index.html');
    let indexHtmlContent = fs.readFileSync(indexHtmlPath, 'utf-8');

    // Find current blazor.webassembly reference
    const blazorWebAssemblyRegex = /blazor\.webassembly\.[a-z0-9]+\.js/;
    const currentMatch = indexHtmlContent.match(blazorWebAssemblyRegex);

    if (currentMatch && currentMatch[0] !== blazorWebAssemblyVersioned) {
        // Replace the old reference with the new one
        indexHtmlContent = indexHtmlContent.replace(blazorWebAssemblyRegex, blazorWebAssemblyVersioned);
        fs.writeFileSync(indexHtmlPath, indexHtmlContent, 'utf-8');
        console.log(`  Updated index.html: ${currentMatch[0]} → ${blazorWebAssemblyVersioned}`);
    } else if (currentMatch && currentMatch[0] === blazorWebAssemblyVersioned) {
        console.log(`  index.html already references correct version: ${blazorWebAssemblyVersioned}`);
    } else {
        console.log(`  Warning: Could not find blazor.webassembly reference in index.html`);
    }
} else {
    console.log("  Error: Could not find versioned blazor.webassembly.*.js file");
    process.exit(1);
}

console.log("");
console.log("Step 4W: Create dotnet.js from versioned file (workaround for .NET 10 RC1/RC2 bug)");
const dotnetVersioned = fs.readdirSync(targetFramework)
    .filter(file => {
        const match = /^dotnet\.[a-z0-9]+\.js$/.test(file);
        const notNativeOrRuntime = !/native|runtime/.test(file);
        return match && notNativeOrRuntime;
    })[0];

if (dotnetVersioned) {
    const dotnetTarget = path.join(targetFramework, 'dotnet.js');
    fs.copyFileSync(
        path.join(targetFramework, dotnetVersioned),
        dotnetTarget
    );
    console.log(`  Created dotnet.js from ${dotnetVersioned}`);
} else {
    console.log("  Error: Could not find versioned dotnet.*.js file");
    process.exit(1);
}

console.log("");
console.log("=====================================");
console.log("Deployment completed successfully!");
console.log("=====================================");
console.log("");
console.log("Next steps:");
console.log("  1. Restart your Vite dev server (Ctrl+C, then pnpm dev)");
console.log("  2. Hard refresh your browser (Ctrl+Shift+R)");
console.log("");

/**
 * Recursively copies a directory tree
 * @param source Source directory path
 * @param target Target directory path
 */
function copyDirectoryRecursive(source: string, target: string): void {
    // Create target directory if it doesn't exist
    if (!fs.existsSync(target)) {
        fs.mkdirSync(target, { recursive: true });
    }

    // Read all items in the source directory
    const items = fs.readdirSync(source);

    for (const item of items) {
        const sourcePath = path.join(source, item);
        const targetPath = path.join(target, item);
        const stat = fs.statSync(sourcePath);

        if (stat.isDirectory()) {
            // Recursively copy subdirectory
            copyDirectoryRecursive(sourcePath, targetPath);
        } else {
            // Copy file
            fs.copyFileSync(sourcePath, targetPath);
        }
    }
}

/**
 * Runs a shell command, terminating this process on error
 * @param command 
 * @param args 
 */
async function runCommand(command: string): Promise<void> {
    const args = command.split(/\s+/);
    if (args.length === 0) return;
    const cmd = args.shift()!;
    console.info(`    🏃 '${cmd}' with args '${args}' in directory '${process.cwd()}'`);

    return new Promise((resolve, reject) => {
        const child = spawn(cmd, args, { stdio: 'inherit', shell: true });

        child.on('close', (code) => {
            if (code !== 0) {
                console.error(`    🏃 Command failed with '${code}'`);
                reject(new Error(`Command failed with exit code ${code}`));
            } else {
                resolve();
            }
        });
    });
}
