/**
 * NEXUS-ULTRA 2050 - ULTIMATE NEURAL ENGINE
 * Fully Synced with your Uploaded Design
 */

const state = {
    isLocked: false,
    memory: JSON.parse(localStorage.getItem('nexus_vault')) || []
};

// --- DOM ELEMENTS MAPPING ---
const els = {
    input: document.querySelector('textarea') || document.getElementById('mainInput'),
    historyList: document.getElementById('historyList') || document.querySelector('.history-container'),
    statusLed: document.getElementById('statusLed') || document.querySelector('.led-small'),
    statusText: document.getElementById('statusText') || document.querySelector('.metric-item span'),
    search: document.getElementById('searchInput') || document.querySelector('input[type="text"]'),
    clock: document.querySelector('.sys-metrics div') || document.getElementById('liveClock')
};

// --- 1. INITIALIZE ---
window.onload = () => {
    updateClock();
    setInterval(updateClock, 1000);
    renderHistory();
    updateLED('sync');
    console.log("Nexus Engine Online. 🚀");
};

// --- 2. CORE ACTIONS ---

// SMART COPY
document.getElementById('copyBtn')?.addEventListener('click', async () => {
    const val = els.input.value.trim();
    if (!val) return triggerStatus('EMPTY', 'red');

    await navigator.clipboard.writeText(val);
    triggerStatus('COPIED', '#00ff9c');
    addToMemory(val);
});

// EXPORT ARCHIVE (.TXT)
document.getElementById('downloadBtn')?.addEventListener('click', () => {
    const val = els.input.value;
    if (!val) return;
    const blob = new Blob([val], { type: 'text/plain' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `Nexus_Log_${Date.now()}.txt`;
    a.click();
    triggerStatus('SAVED', '#3f7eff');
});

// WIPE ENGINE (Clear)
document.getElementById('clearBtn')?.addEventListener('click', () => {
    if (confirm("Purge Neural Memory?")) {
        els.input.value = '';
        state.memory = [];
        localStorage.removeItem('nexus_vault');
        renderHistory();
        triggerStatus('PURGED', 'orange');
    }
});

// VOICE INPUT
document.getElementById('micBtn')?.addEventListener('click', () => {
    const Speech = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!Speech) return alert("Browser not supported!");
    const rec = new Speech();
    rec.onstart = () => triggerStatus('LISTENING', '#bc13fe');
    rec.onresult = (e) => {
        els.input.value += " " + e.results[0][0].transcript;
        triggerStatus('SYNCED', '#00ff9c');
    };
    rec.start();
});

// --- 3. UTILITIES ---

function addToMemory(txt) {
    state.memory = [txt, ...state.memory.filter(i => i !== txt)].slice(0, 10);
    localStorage.setItem('nexus_vault', JSON.stringify(state.memory));
    renderHistory();
}

function renderHistory() {
    const list = document.getElementById('historyList');
    if (!list) return;
    list.innerHTML = state.memory.map(item => `
        <div class="history-card" style="cursor:pointer; margin-bottom:8px;" onclick="restore('${item.replace(/'/g, "\\'")}')">
          <span style="font-size:12px; opacity:0.8;">${item.substring(0, 30)}...</span>
        </div>
    `).join('');
}

window.restore = (txt) => {
    els.input.value = txt;
    triggerStatus('RESTORED', '#3f7eff');
};

function triggerStatus(msg, color) {
    if (els.statusLed) {
        els.statusLed.style.background = color;
        els.statusLed.style.boxShadow = `0 0 10px ${color}`;
    }
    setTimeout(() => {
        if (els.statusLed) {
            els.statusLed.style.background = '#3dd68c';
            els.statusLed.style.boxShadow = 'none';
        }
    }, 2000);
}

function updateClock() {
    const clock = document.querySelector('.sys-metrics div') || document.querySelector('header span');
    if (clock) {
        const now = new Date();
        clock.innerText = now.toLocaleTimeString();
    }
}

// Search Filter
els.search?.addEventListener('input', (e) => {
    const term = e.target.value.toLowerCase();
    document.querySelectorAll('.history-card').forEach(card => {
        card.style.display = card.innerText.toLowerCase().includes(term) ? 'flex' : 'none';
    });
});
 
