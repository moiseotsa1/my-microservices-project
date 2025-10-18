// Script pour ajouter les onglets manquants au frontend
const fs = require('fs');

// Lire le fichier App.jsx
let appContent = fs.readFileSync('frontend/src/App.jsx', 'utf8');

// Ajouter les onglets Payment et Notification dans la navigation
if (!appContent.includes('Paiements') && !appContent.includes('Notifications')) {
  // Trouver la section des tabs et ajouter les nouveaux boutons
  const tabsRegex = /<nav className="tabs">([\s\S]*?)<\/nav>/;
  const match = appContent.match(tabsRegex);
  
  if (match) {
    const newTabs = match[0].replace('</nav>', 
      `        <button 
          className={activeTab === 'payments' ? 'active' : ''}
          onClick={() => setActiveTab('payments')}
        >
          💳 Paiements
        </button>
        <button 
          className={activeTab === 'notifications' ? 'active' : ''}
          onClick={() => setActiveTab('notifications')}
        >
          🔔 Notifications
        </button>
      </nav>`
    );
    
    appContent = appContent.replace(tabsRegex, newTabs);
    
    // Ajouter les composants pour les nouveaux onglets
    const mainContent = `
        {activeTab === 'payments' && (
          <div className="tab-content">
            <h2>💳 Gestion des Paiements</h2>
            <div className="list">
              <h3>Service Payment (Port 3004)</h3>
              <div className="card">
                <strong>Fonctionnalités:</strong>
                <div>• Traitement des paiements</div>
                <div>• Historique des transactions</div>
                <div>• Statuts de paiement</div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'notifications' && (
          <div className="tab-content">
            <h2>🔔 Gestion des Notifications</h2>
            <div className="list">
              <h3>Service Notification (Port 3005)</h3>
              <div className="card">
                <strong>Fonctionnalités:</strong>
                <div>• Envoi de notifications</div>
                <div>• Types: email, SMS, push</div>
                <div>• Historique des envois</div>
              </div>
            </div>
          </div>
        )}
    `;
    
    // Insérer avant la fermeture du main
    appContent = appContent.replace('      </main>', `${mainContent}\n      </main>`);
    
    fs.writeFileSync('frontend/src/App.jsx', appContent);
    console.log('✅ Frontend mis à jour avec les nouveaux onglets !');
  }
}
