// // Set clock speed to 16MHz
// avrdude -v -p attiny85 -c usbtiny -B8 -e -U lfuse:w:0b11110011:m
// // Set clock speed to 8MHz
// avrdude -v -p attiny85 -c usbtiny -B8 -e -U lfuse:w:0b11100010:m
// // Set clock speed to 1MHz
// avrdude -v -p attiny85 -c usbtiny -B8 -e -U lfuse:w:0b01100010:m

const { doSpawn, exitWithError, bigMsg, avrdudeDepWarning, filterMatchingLogs } = require("./shared/utils");

const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')

async function main() {
    let { device, fuse, bits } = await yargs(hideBin(process.argv))
        .option('device', {
            type: 'string',
            description: 'The device to upload to (ex. "attiny85")',
            requiresArg: true,
        })
        .option('fuse', {
            type: 'string',
            description: 'The name of the fuse to set (ex. "lfuse")',
            requiresArg: true,
        })
        .option('bits', {
            type: 'string',
            description: 'The bits to set to the fuse (ex. "01100010")',
            requiresArg: true,

        })
        .parse()

    if (!device) {
        exitWithError('Expected a "device" option.');
    }

    if (!fuse) {
        exitWithError('Expected a "fuse" option.');
    }
    if (!/^\w+fuse$/.test(fuse)) {
        exitWithError('Expected "fuse" to match "/^\\w+fuse$/".');
    }

    if (!bits) {
        exitWithError('Expected a "bits" option.');
    }
    if (!/^[10]{8}$/.test(bits)) {
        exitWithError('Expected "bits" to match "/^[10]{8}$/".');
    }

    bigMsg(`Uploading "${bits}" to "${device}" -> "${fuse}"`);

    await doSpawn(
        `avrdude -v -p ${device} -c usbtiny -B8 -e -U ${fuse}:w:0b${bits}:m`,
        filterMatchingLogs([avrdudeDepWarning])
    )

}

main();