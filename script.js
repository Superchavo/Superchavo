// Manejador del botón de copiado del repositorio
document.addEventListener('DOMContentLoaded', () => {
    const copyBtn = document.getElementById('copyBtn');
    
    if (copyBtn) {
        copyBtn.addEventListener('click', () => {
            const commandText = "git clone https://github.com/Superchavo/NeeXtraRepo.git && cd NeeXtraRepo && chmod +x installer.sh && ./installer.sh";
            
            navigator.clipboard.writeText(commandText).then(() => {
                // Estado copiado exitosamente
                copyBtn.textContent = "Copied!";
                copyBtn.classList.add('success');
                
                // Revertir estado original después de 2 segundos
                setTimeout(() => {
                    copyBtn.textContent = "Copy";
                    copyBtn.classList.remove('success');
                }, 2000);
            }).catch(err => {
                console.error('Error al copiar el comando: ', err);
            });
        });
    }
});
