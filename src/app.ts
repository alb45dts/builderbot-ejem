import { join } from 'path'
import {
createBot,
createProvider,
createFlow,
addKeyword,
utils,
MemoryDB,
} from '@builderbot/bot'
import { BaileysProvider } from '@builderbot/provider-baileys'

const PORT = Number(process.env.PORT ?? 3008)

const welcomeFlow = addKeyword(['hi', 'hello', 'hola'])
.addAnswer('Ey! welcome')
.addAnswer(
'Your name is?',
{ capture: true, delay: 800 },
async (ctx, { flowDynamic }) => {
await flowDynamic([nice! ${ctx.body}, 'I will send you a funny image'])
}
)
.addAction(async (_, { flowDynamic }) => {
const dataApi = await fetch(
'https://shibe.online/api/shibes?count=1&urls=true&httpsUrls=true'
)
const [imageUrl] = (await dataApi.json()) as string[]
await flowDynamic([{ body: '😜', media: imageUrl }])
})
.addAnswer('also you can write "samples"')

const fullSamplesFlow = addKeyword(['sample', utils.setEvent('SAMPLES')])
.addAnswer(💪 I'll send you a lot files...)
.addAnswer(Send image from Local, {
media: join(process.cwd(), 'assets', 'sample.png'),
})
.addAnswer(Send video from URL, {
media:
'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYTJ0ZGdjd2syeXAwMjQ4aWdkcW04OWlqcXI3Ynh1ODkwZ25zZWZ1dCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/LCohAb657pSdHv0Q5h/giphy.mp4',
})
.addAnswer(Send audio from URL, {
media: 'https://cdn.freesound.org/previews/728/728142_11861866-lq.mp3',
})
.addAnswer(Send file from URL, {
media:
'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
})

async function main() {
console.log('[builderbot] Booting...')

const adapterFlow = createFlow([welcomeFlow, fullSamplesFlow])
const adapterProvider = createProvider(BaileysProvider)
const adapterDB = new MemoryDB()

const { handleCtx, httpServer } = await createBot({
flow: adapterFlow,
provider: adapterProvider,
database: adapterDB,
})

// Endpoint de salud para probar que el server responde
adapterProvider.server.get('/health', (_req, res) => {
res.end('ok')
})

// Logs útiles de estado
adapterProvider.on('ready', () => {
console.log('[builderbot] WhatsApp session ready ✅')
})
adapterProvider.on('host', ({ phone }) => {
console.log('[builderbot] Host detected:', phone)
setTimeout(async () => {
