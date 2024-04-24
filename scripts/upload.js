const { stat } = require('node:fs/promises')
const { resolve } = require('node:path')
const { doSpawn, exitWithError, bigMsg, filterMatchingLogs, avrdudeDepWarning } = require("./shared/utils");

const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')

async function main() {
    let { device, file } = await yargs(hideBin(process.argv))
        .option('device', {
            type: 'string',
            description: 'The device to upload to (ex. "attiny85")',
            requiresArg: true,
        })
        .option('file', {
            type: 'string',
            description: 'The name of the ".asm" file to assemble (ex. "blink")',
            requiresArg: true,
        })
        .parse()

    if (!device) {
        exitWithError('Expected a "device" option.');
    }

    if (!file) {
        exitWithError('Expected a "file" option.');
    }

    if (!/\.asm$/.test(file)) {
        file += '.asm'
    }

    const filePath = resolve(__dirname, '../', file);
    const outPath = resolve(__dirname, '../', 'out.hex');

    const statRes = await stat(filePath).catch(() => undefined)
    if (!statRes || !statRes.isFile()) {
        exitWithError(`"${filePath}" is not a file.`)
    }

    bigMsg(`Building "${filePath}"`);

    await doSpawn(
        `avra -o ${outPath} ${filePath}`,
        filterMatchingLogs([/directive currently ignored$/i])
    )

    bigMsg(`Uploading to "${device}"`);

    await doSpawn(
        `avrdude -c usbtiny -b 19200 -p ${device} -U flash:w:${outPath}`,
        filterMatchingLogs([avrdudeDepWarning])
    )
}

main();