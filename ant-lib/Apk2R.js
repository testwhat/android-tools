/*
 * Copyright (C) 2014 Riddle Hsu
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* TODO
1.Proguarded apk: search package-name.* to find source is R.java
2.If exist R$styleable, restore it to R:

#input:
public final class R { // from this script
    public static final class attr {
        public static final int amPmStyle=0x7f010029; // 2130772009
public final class R$styleable { // from dex to java
    public static final int[] Clock = new int[]{R.attr.amPmStyle};
#output:
R.styleable.Clock = { 2130772009 };
R.styleable.Clock_amPmStyle = 0; // index in R.styleable.Clock
*/
'use strict';
try { // For compatibility of importPackage with Java 8 (Nashorn engine)
    load("nashorn:mozilla_compat.js");
} catch (e) {
}

importPackage(java.lang);
importPackage(java.io);

// Parameter: AAPT_EXEC, inputApkFile, outputDir
function apk2RresourceJava() {
    if (typeof AAPT_EXEC == 'undefined') {
        System.out.println('AAPT_EXEC is undefined');
        System.exit(0);
    }

    if (typeof inputApkFile != 'string') {
        System.out.println('Invalid input');
        System.exit(0);
    }
    inputApkFile = new File(inputApkFile);
    var outputPath = inputApkFile.getParentFile();
    if (typeof outputDir != 'undefined' && typeof outputDir == 'string') {
        outputPath = new File(outputDir);
    }

    genRJavaByAapt(inputApkFile, new File(outputPath, 'R.java'));
}

function getPackageNameFromApk(apkFile) {
    var PKP = "package: name='";
    var pkgName = null;
    var aapt = Runtime.getRuntime().exec(AAPT_EXEC + ' dump badging ' + apkFile);
    var r = new BufferedReader(new InputStreamReader(aapt.getInputStream(), 'utf-8'))
    var line;
    while ((line = r.readLine()) != null) {
        if (line.startsWith(PKP)) {
            pkgName = line.substring(PKP.length(), line.indexOf('\'', PKP.length()));
            break;
        }
    }
    r.close();
    aapt.destroy();
    return pkgName;
}

function genRJavaByAapt(apkFile, outputFile) {
    var SRES = 'spec resource ';
    var SRES_L = SRES.length();

    var pkgName = getPackageNameFromApk(apkFile);
    if (pkgName == null) {
        System.out.println('getPackageNameFromApk cannot get pkg name');
        return;
    }

    var pnLen = pkgName.length();
    var aapt = Runtime.getRuntime().exec(AAPT_EXEC + ' d --values resources ' + apkFile);
    var r = new BufferedReader(new InputStreamReader(aapt.getInputStream(), 'utf-8'));
    var bw = new BufferedWriter(new FileWriter(outputFile));
    bw.append('package ' + pkgName + ';\n\n');
    bw.append("public final class R {\n");
    var currentType = null;
    var begin = false;
    var line = null;
    while ((line = r.readLine()) != null) {
        if (!begin) {
            if (line.startsWith('Package Group') && line.contains(pkgName)) {
                begin = true;
            }
            continue;
        }
        line = line.trim();
        if (line.startsWith(SRES)) {
            // spec resource 0x7f09000f
            // com.android.settings:id/switchWidget:
            // flags=0x00000000
            var value = line.substring(SRES_L, SRES_L + 10);
            var typeStart = SRES_L + 12 + pnLen;
            var tname = line.substring(typeStart, line.indexOf(':', typeStart));
            var d = tname.indexOf('/');
            var type = tname.substring(0, d);
            var name = tname.substring(d + 1).replaceAll('\\.', '_');
            //System.out.println(type + ': ' + name + ' = ' + value);
            if (currentType == null) {
                bw.append('    public static final class ' + type + ' {\n');
            } else if (!currentType.equals(type)) {
                bw.append('    }\n');
                bw.append('    public static final class ' + type + ' {\n');
            }
            bw.append('        public static final int ' + name + '=' + value + ';\n');
            currentType = type;
        }
    }
    bw.append('    }\n');
    bw.append('}\n');
    bw.close();
    r.close();
    aapt.destroy();
    System.out.println('Write to ' + outputFile);
}
