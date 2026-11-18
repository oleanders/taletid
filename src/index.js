import './main.css'
import registerServiceWorker from './registerServiceWorker'

window.Elm.Main.init({ node: document.getElementById('root'), flags: { currentTime: Date.now() } })

registerServiceWorker()
