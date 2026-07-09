document.addEventListener('DOMContentLoaded', () => {
    const xdeWindow = document.getElementById('xdeWindow');
    const btnMinimize = document.getElementById('btnMinimize');
    const btnMaximize = document.getElementById('btnMaximize');
    const btnClose = document.getElementById('btnClose');
    const kickerClock = document.getElementById('kickerClock');

    // 1. Maximize and Enable Real Fullscreen
    btnMaximize.addEventListener('click', () => {
        if (!document.fullscreenElement) {
            // Changed to documentElement to make the whole browser fullscreen
            document.documentElement.requestFullscreen().catch(err => {
                console.error(`Error attempting to enable full-screen mode: ${err.message}`);
            });
        } else {
            document.exitFullscreen();
        }
    });

    // 2. Minimize window (Visual effect)
    btnMinimize.addEventListener('click', () => {
        xdeWindow.classList.add('minimized');
        setTimeout(() => {
            alert("Xonsole minimized. Click OK to restore it to the workspace.");
            xdeWindow.classList.remove('minimized');
        }, 350);
    });

    // 3. Close window (Simulation)
    btnClose.addEventListener('click', () => {
        if (confirm("Do you want to close the current Xonsole session?")) {
            xdeWindow.innerHTML = `
                <div style="padding: 50px 20px; text-align: center; font-family: monospace; color: #da4453;">
                    <h3 style="margin: 0 0 10px 0;">[PROCESS COMPLETED]</h3>
                    <p style="color: #7f8c8d; margin: 0;">Session terminated safely.</p>
                </div>
            `;
            setTimeout(() => { location.reload(); }, 2500);
        }
    });

    // 4. Dynamic clock for the Kicker Panel
    function updateClock() {
        const now = new Date();
        // Using toLocaleTimeString for cleaner code
        if (kickerClock) {
            kickerClock.textContent = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
        }
    }
    
    setInterval(updateClock, 1000);
    updateClock();
});
