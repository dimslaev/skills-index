import type { Register } from 'claude-code'

const INDEX = '/Users/dimitar/.agents/skills-index.txt'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'index', description: 'Show all skills with codes like P1' })
    return next(e)
  })

  on('command.run', { command: 'index' }, async $ => {
    const text = await $.fs.read(INDEX)
    // context: the model reads the codes with the next prompt, so "B2 <task>" works
    return { text, context: [text] }
  })
}
