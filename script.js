/**
 * NEXUS-ULTRA 2050 - GLOBAL INTELLIGENCE ENGINE
 * Developed by Gemini for Gurshak
 * Features: AI Memory, Voice-to-Text, Security Lock, & Neural Sync
 */

const els = {
    input: document.getElementById('mainInput'),
    list: document.getElementById('historyList'),
    led: document.getElementById('statusLed'),
    status: document.getElementById('statusText'),
    search: document.getElementById('searchInput'),
    tokens: document.getElementById('tokenCount'),
    lockBtn: document.getElementById('lockBtn')
};

let isLocked = false;

// --- 1. INITIALIZATION ---
window.onload = () => {
    // LocalStorage se purani yaadein (Memory) nikalna
    const memory = JSON.parse(localStorage.getItem('nexus_v2')) || [];
    renderHistory(memory);
    
    // Live Clock Start
    setInterval(updateClock, 1000);
    updateClock();
    
    console.log("Nexus Engine: Online & Synced. 🚀");
};

// --- 2. SMART COPY & SAVE ---
document.getElementById('copyBtn').onclick = async () => {
    if (isLocked) return triggerStatus('LOCKED', '#ff3b3b');
    
    const val = els.input.value.trim();
    if (!val) return triggerStatus('EMPTY', '#ff3b3b');

    try {
        await navigator.clipboard.writeText(val);
        triggerStatus('COPIED', '#00ff9c'); // Green LED
        saveToVault(val);
    } catch (err) {
        triggerStatus('ERROR', '#ff3b3b');
    }
};

// --- 3. DATA VAULT (Memory Management) ---
function saveToVault(txt) {
    let memory = JSON.parse(localStorage.getItem('nexus_v2')) || [];
    // Duplicate hatana aur sirf top 10 items rakhna
    memory = [txt, ...memory.filter(i => i !== txt)].slice(0, 10);
    localStorage.setItem('nexus_v2', JSON.stringify(memory));
    renderHistory(memory);
}

function renderHistory(items) {
    if (items.length === 0) {
        document.getElementById('emptyMsg').style.display = 'block';
        els.list.innerHTML = '';
        return;
    }
    
    document.getElementById('emptyMsg').style.display = 'none';
    els.list.innerHTML = items.map(item => `
        <div class="history-card" onclick="restoreFromVault('${item.replace(/'/g, "\\'")}')">
          <span>${item.substring(0, 35)}${item.length > 35 ? '...' : ''}</span>
          <i class="fas fa-redo-alt redo-icon" style="color:#00eaff; font-size:10px;"></i>
        </div>
    `).join('');
}

function restoreFromVault(txt) {
    if (isLocked) return;
    els.input.value = txt;
    updateStats();
    triggerStatus('RESTORED', '#2f7cff'); // Blue LED
}

// --- 4. VOICE INTELLIGENCE (Speech to Text) ---
document.getElementById('micBtn').onclick = () => {
    if (isLocked) return;
    const Speech = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!Speech) return alert("Bhai, aapka browser voice support nahi karta!");

    const recognition = new Speech();
    recognition.onstart = () => triggerStatus('LISTENING', '#a855ff'); // Purple LED
    
    recognition.onresult = (e) => {
        const transcript = e.results[0][0].transcript;
        els.input.value += (els.input.value ? " " : "") + transcript;
        updateStats();
        triggerStatus('SYNCING', '#2f7cff');
    };
    recognition.start();
};

// --- 5. BIOMETRIC LOCK SYSTEM ---
els.lockBtn.onclick = function() {
    isLocked = !isLocked;
    els.input.disabled = isLocked;
    
    // UI Update
    this.innerHTML = isLocked ? '<i class="fas fa-lock"></i>' : '<i class="fas fa-unlock"></i>';
    this.style.color = isLocked ? '#ff3b3b' : '#00eaff';
    
    triggerStatus(isLocked ? 'LOCKED' : 'UNLOCKED', isLocked ? '#ff3b3b' : '#00ff9c');
};

// --- 6. UTILITIES (Wipe, Export, Stats) ---
document.getElementById('clearBtn').onclick = () => {
    if (confirm("Confirm Permanent Memory Wipe?")) {
        localStorage.removeItem('nexus_v2');
        renderHistory([]);
        els.input.value = '';
        updateStats();
        triggerStatus('PURGED', '#ff3b3b');
    }
};

document.getElementById('downloadBtn').onclick = () => {
    const blob = new Blob([els.input.value], { type: 'text/plain' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `Nexus_Export_${Date.now()}.txt`;
    a.click();
    triggerStatus('EXPORTED', '#00ff9c');
};

function triggerStatus(msg, col) {
    els.status.innerText = msg;
    els.led.style.background = col;
    els.led.style.boxShadow = `0 0 15px ${col}`;
    
    // 2 second baad wapas normal standby mode
    setTimeout(() => {
        els.status.innerText = isLocked ? 'LOCKED' : 'SYNCING';
        els.led.style.background = isLocked ? '#ff3b3b' : '#2f7cff';
        els.led.style.boxShadow = isLocked ? `0 0 10px #ff3b3b` : 'none';
    }, 2000);
}

function updateStats() {
    const val = els.input.value;
    if (els.tokens) {
        els.tokens.innerText = `Tokens: ${Math.ceil(val.length / 4)}`;
    }
}

function updateClock() {
    const clock = document.getElementById('liveClock');
    if (clock) clock.innerText = new Date().toLocaleTimeString();
}

// Live Search Filter
els.search.oninput = (e) => {
    const term = e.target.value.toLowerCase();
    document.querySelectorAll('.history-card').forEach(card => {
        card.style.display = card.innerText.toLowerCase().includes(term) ? 'flex' : 'none';
    });
};

// Live Input Analytics
els.input.oninput = updateStats;
