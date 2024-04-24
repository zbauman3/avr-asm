const util = require('node:util');
const { spawn } = require('node:child_process')

const avrdudeDepWarning = /^avrdude warning:[^\n]+deprecated/i

const exitWithError = (msg) => {
    console.error(msg)
    process.exit(1);
}

const doSpawn = async (inp, filter = (i) => i) => new Promise((res) => {
    const [cmd, ...args] = inp.split(/\s/);
    let type = 'log', logs = ''

    const ch = spawn(cmd, args, { stdio: ['inherit', 'pipe', 'pipe'] })

    ch.stdout.on('data', (data) => { logs += data.toString() });
    ch.stderr.on('data', (data) => { type = 'error'; logs += data.toString() });
    ch.on('error', (code) => { console[type](filter(logs)); console.error('ERROR: ', code); process.exit(1) });
    ch.on('exit', (code) => {
        console[type](filter(logs));
        if (typeof code === 'number' && code !== 0) {
            process.exit(code)
        }
        res();
    });
})

const bigMsg = (msg) => {
    console.log('\n')
    console.log('-'.repeat(msg.length))
    console.log(msg)
    console.log('-'.repeat(msg.length))
    console.log('\n')
}

const filterMatchingLogs = (
    /** @type {RegExp[]} */
    patterns
) =>
    (logs) => logs.trim().split('\n').filter(
        (line) => !patterns.some((pattern) => pattern.test(line.trim()))
    ).join('\n')

module.exports = { exitWithError, doSpawn, bigMsg, filterMatchingLogs, avrdudeDepWarning }