#!/bin/bash

echo "🎨 MISE À JOUR DU FRONTEND AVEC LES NOUVEAUX SERVICES"
echo "===================================================="

# Ajout des nouveaux services dans App.jsx
cat >> frontend/src/App.jsx << 'UPDATE'

        {activeTab === 'payments' && (
          <div className="tab-content">
            <h2>💳 Gestion des Paiements</h2>
            
            <form onSubmit={addPayment} className="form">
              <h3>Traiter un paiement</h3>
              <input
                type="number"
                placeholder="ID Commande"
                value={newPayment.order_id}
                onChange={(e) => setNewPayment({...newPayment, order_id: e.target.value})}
                required
              />
              <input
                type="number"
                step="0.01"
                placeholder="Montant"
                value={newPayment.amount}
                onChange={(e) => setNewPayment({...newPayment, amount: e.target.value})}
                required
              />
              <select
                value={newPayment.payment_method}
                onChange={(e) => setNewPayment({...newPayment, payment_method: e.target.value})}
                required
              >
                <option value="">Méthode de paiement</option>
                <option value="credit_card">Carte de crédit</option>
                <option value="paypal">PayPal</option>
                <option value="bank_transfer">Virement bancaire</option>
              </select>
              <button type="submit">Traiter Paiement</button>
            </form>

            <div className="list">
              <h3>Historique des paiements ({payments.length})</h3>
              {payments.map(payment => (
                <div key={payment.id} className="card">
                  <strong>Paiement #{payment.id}</strong>
                  <div>📦 Commande: {payment.order_id}</div>
                  <div>👤 Client: {payment.user_email}</div>
                  <div>💰 Montant: {parseFloat(payment.amount).toFixed(2)}€</div>
                  <div>💳 Méthode: {payment.payment_method}</div>
                  <div>📋 Statut: <span className={`status ${payment.status}`}>{payment.status}</span></div>
                  <small>Traité le {new Date(payment.created_at).toLocaleDateString()}</small>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'notifications' && (
          <div className="tab-content">
            <h2>🔔 Gestion des Notifications</h2>
            
            <form onSubmit={sendNotification} className="form">
              <h3>Envoyer une notification</h3>
              <input
                type="number"
                placeholder="ID Utilisateur"
                value={newNotification.user_id}
                onChange={(e) => setNewNotification({...newNotification, user_id: e.target.value})}
                required
              />
              <select
                value={newNotification.type}
                onChange={(e) => setNewNotification({...newNotification, type: e.target.value})}
                required
              >
                <option value="">Type de notification</option>
                <option value="order_confirmation">Confirmation commande</option>
                <option value="payment_success">Paiement réussi</option>
                <option value="shipping_update">Mise à jour expédition</option>
                <option value="promotional">Promotion</option>
              </select>
              <input
                type="text"
                placeholder="Titre"
                value={newNotification.title}
                onChange={(e) => setNewNotification({...newNotification, title: e.target.value})}
                required
              />
              <textarea
                placeholder="Message"
                value={newNotification.message}
                onChange={(e) => setNewNotification({...newNotification, message: e.target.value})}
                required
              />
              <button type="submit">Envoyer Notification</button>
            </form>

            <div className="list">
              <h3>Historique des notifications ({notifications.length})</h3>
              {notifications.map(notification => (
                <div key={notification.id} className="card">
                  <div className="notification-header">
                    <strong>{notification.title}</strong>
                    <span className={`notification-badge ${notification.type}`}>
                      {notification.type}
                    </span>
                  </div>
                  <div>👤 User ID: {notification.user_id}</div>
                  <div>📨 {notification.message}</div>
                  <div>📋 Statut: {notification.read ? '✅ Lu' : '📧 Non lu'}</div>
                  <small>Envoyé le {new Date(notification.created_at).toLocaleString()}</small>
                </div>
              ))}
            </div>
          </div>
        )}
UPDATE

echo "✅ Frontend mis à jour avec les nouveaux services !"
echo ""
echo "🔄 Redémarrage du frontend nécessaire pour voir les changements"
