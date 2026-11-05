import React, { useState, useEffect } from 'react';
import './App.css';
import LogForm from './components/LogForm';
import LogList from './components/LogList';
import ExecutionLogForm from './components/ExecutionLogForm';
import ExecutionLogList from './components/ExecutionLogList';
import ExportLogList from './components/ExportLogList';

function App() {
  const [logs, setLogs] = useState([]);
  const [executionLogs, setExecutionLogs] = useState([]);
  const [exportLogs, setExportLogs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [executionLoading, setExecutionLoading] = useState(false);
  const [exportLoading, setExportLoading] = useState(false);
  const [error, setError] = useState(null);
  const [activeTab, setActiveTab] = useState('commands'); // 'commands', 'executions', or 'exports'

  // Use environment variable or detect current hostname
  const API_URL = `http://${window.location.hostname}:5000/api`;

  // Fetch logs
  const fetchLogs = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_URL}/logs`);
      const data = await response.json();

      if (data.success) {
        setLogs(data.data);
      } else {
        setError(data.error || 'Failed to fetch logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Create log
  const createLog = async (logData) => {
    try {
      const response = await fetch(`${API_URL}/logs`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(logData),
      });

      const data = await response.json();

      if (data.success) {
        fetchLogs(); // Refresh the list
        return { success: true };
      } else {
        return { success: false, error: data.error };
      }
    } catch (err) {
      return { success: false, error: 'Error connecting to server: ' + err.message };
    }
  };

  // Delete log
  const deleteLog = async (id) => {
    try {
      const response = await fetch(`${API_URL}/logs/${id}`, {
        method: 'DELETE',
      });

      const data = await response.json();

      if (data.success) {
        fetchLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to delete log');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  // Update log status
  const updateLogStatus = async (id, status) => {
    try {
      const response = await fetch(`${API_URL}/logs/${id}/status`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status }),
      });

      const data = await response.json();

      if (data.success) {
        fetchLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to update status');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  // Clear all logs
  const clearAllLogs = async () => {
    if (!window.confirm('Are you sure you want to clear all logs?')) {
      return;
    }

    try {
      const response = await fetch(`${API_URL}/logs`, {
        method: 'DELETE',
      });

      const data = await response.json();

      if (data.success) {
        fetchLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to clear logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };
  const getTimestamp = () => {
    const now = new Date();
    const pad = (n) => String(n).padStart(2, '0');
    return `${String(now.getFullYear()).slice(-2)}${pad(now.getMonth() + 1)}${pad(now.getDate())}${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`;
  };
  // Export database - insert mysqldump command into logs
  const exportDatabase = async (database) => {
    const timestamp = getTimestamp();
    const commands = {
      logdb: `mysqldump --skip-add-drop-table --complete-insert -h 127.0.0.1 -u root -prootpassword logdb > backup_${timestamp}.sql`,
      logdbqa: `mysqldump -h 127.0.0.1 -u root -prootpassword logdbqa > backup_qa_${timestamp}.sql`,
      logdbprod: `mysqldump -h 127.0.0.1 -u root -prootpassword logdbprod > backup_prod_${timestamp}.sql`
    };

    const command = commands[database];
    if (!command) return;

    const result = await createLog({
      message: command,
      status: 'pending'
    });

    if (result.success) {
      alert(`Database export command added: ${database}`);
    } else {
      alert(`Failed to add export command: ${result.error}`);
    }
  };

  // Import database from an existing successful export_log entry
  // Constructs: mysql -h 127.0.0.1 -u root -prootpassword <db> < "filename.sql"
  const importFromBackup = async (exportId) => {
    const entry = exportLogs.find((e) => String(e.id) === String(exportId));
    if (!entry) return;

    // Only allow successful exports to be imported
    if (entry.status !== 'success') {
      alert('Only successful exports can be imported.');
      return;
    }

    const db = entry.database_name;
    const file = entry.filename;
    // Drop/recreate DB, then import with FK checks disabled in a single session using shell script
    const command = `mysql -h 127.0.0.1 -u root -prootpassword -e "DROP DATABASE IF EXISTS ${db}; CREATE DATABASE ${db};" && (echo "SET FOREIGN_KEY_CHECKS=0;" && cat "${file}" && echo "SET FOREIGN_KEY_CHECKS=1;") | mysql -h 127.0.0.1 -u root -prootpassword ${db}`;

    const result = await createLog({
      message: command,
      status: 'pending',
    });

    if (result.success) {
      alert(`Database import command added: ${db} <- ${file}`);
    } else {
      alert(`Failed to add import command: ${result.error}`);
    }
  };

  // ========== Execution Log Functions ==========

  // Fetch execution logs
  const fetchExecutionLogs = async () => {
    setExecutionLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_URL}/execution-logs`);
      const data = await response.json();

      if (data.success) {
        setExecutionLogs(data.data);
      } else {
        setError(data.error || 'Failed to fetch execution logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    } finally {
      setExecutionLoading(false);
    }
  };

  // Create execution log
  const createExecutionLog = async (logData) => {
    try {
      const response = await fetch(`${API_URL}/execution-logs`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(logData),
      });

      const data = await response.json();

      if (data.success) {
        fetchExecutionLogs(); // Refresh the list
        return { success: true };
      } else {
        return { success: false, error: data.error };
      }
    } catch (err) {
      return { success: false, error: 'Error connecting to server: ' + err.message };
    }
  };

  // Delete execution log
  const deleteExecutionLog = async (id) => {
    try {
      const response = await fetch(`${API_URL}/execution-logs/${id}`, {
        method: 'DELETE',
      });

      const data = await response.json();

      if (data.success) {
        fetchExecutionLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to delete execution log');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  // Clear all execution logs
  const clearAllExecutionLogs = async () => {
    if (!window.confirm('Are you sure you want to clear all execution logs?')) {
      return;
    }

    try {
      const response = await fetch(`${API_URL}/execution-logs`, {
        method: 'DELETE',
      });

      const data = await response.json();

      if (data.success) {
        fetchExecutionLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to clear execution logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  // ========== Export Log Functions ==========

  // Fetch export logs
  const fetchExportLogs = async () => {
    setExportLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_URL}/export-logs`);
      const data = await response.json();

      if (data.success) {
        setExportLogs(data.data);
      } else {
        setError(data.error || 'Failed to fetch export logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    } finally {
      setExportLoading(false);
    }
  };

  // Delete export log
  const deleteExportLog = async (id) => {
    try {
      const response = await fetch(`${API_URL}/export-logs/${id}`, {
        method: 'DELETE',
      });

      const data = await response.json();

      if (data.success) {
        fetchExportLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to delete export log');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  // Clear all export logs
  const clearAllExportLogs = async () => {
    if (!window.confirm('Are you sure you want to clear all export logs?')) {
      return;
    }

    try {
      const response = await fetch(`${API_URL}/export-logs`, {
        method: 'DELETE',
      });

      const data = await response.json();

      if (data.success) {
        fetchExportLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to clear export logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  useEffect(() => {
    fetchLogs();
    fetchExecutionLogs();
    fetchExportLogs();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>📝 MariaDB migrate Manager</h1>
        <p>Net23000 class project</p>
        <h2>Update engine.sh with your database connection details</h2>
      </header>

      <main className="App-main">
        <div className="container">
          {/* Tab Navigation */}
          <div className="tab-navigation">
            <button
              className={`tab-button ${activeTab === 'commands' ? 'active' : ''}`}
              onClick={() => setActiveTab('commands')}
            >
              📋 Commands
            </button>
            <button
              className={`tab-button ${activeTab === 'executions' ? 'active' : ''}`}
              onClick={() => setActiveTab('executions')}
            >
              ⚙️ Execution Logs
            </button>
            <button
              className={`tab-button ${activeTab === 'exports' ? 'active' : ''}`}
              onClick={() => setActiveTab('exports')}
            >
              💾 Export Logs
            </button>
          </div>

          {/* Commands Tab */}
          {activeTab === 'commands' && (
            <>
              {/* Log Form Section */}
              <section className="card">
                <div className="logs-header">
                  <div className="controls">
                    {/* Import from existing backups (export_log with success) */}
                    <div className="dropdown" style={{ marginRight: '10px' }}>
                      <select
                        onChange={(e) => {
                          if (e.target.value) {
                            importFromBackup(e.target.value);
                            e.target.value = '';
                          }
                        }}
                        className="btn btn-primary"
                      >
                        <option value="">⬇️ Import From Backup</option>
                        {exportLogs
                          .filter((e) => e.status === 'success')
                          .map((e) => (
                            <option key={e.id} value={e.id}>
                              {e.database_name} — {e.filename}
                            </option>
                          ))}
                      </select>
                    </div>
                    <div className="dropdown">
                      <select
                        onChange={(e) => {
                          if (e.target.value) {
                            exportDatabase(e.target.value);
                            e.target.value = ''; // Reset dropdown
                          }
                        }}
                        className="btn btn-primary"
                      >
                        <option value="">💾 Export Database</option>
                        <option value="logdb">Export logdb</option>
                        <option value="logdbqa">Export logdbqa</option>
                        <option value="logdbprod">Export logdbprod</option>
                      </select>
                    </div>
                  </div>
                </div>
                {/* <LogForm onSubmit={createLog} /> */}
              </section>

              {/* Log List Section */}
              <section className="card">
                <div className="logs-header">
                  <h2>Command Entries</h2>
                  <div className="controls">
                    <button onClick={fetchLogs} className="btn btn-secondary">
                      🔄 Refresh
                    </button>
                    <button onClick={clearAllLogs} className="btn btn-danger">
                      🗑️ Clear All
                    </button>
                  </div>
                </div>

                {error && <div className="error-message">{error}</div>}
                {loading ? (
                  <div className="loading">Loading Command...</div>
                ) : (
                  <LogList logs={logs} onDelete={deleteLog} onStatusChange={updateLogStatus} />
                )}
              </section>
            </>
          )}

          {/* Execution Logs Tab */}
          {activeTab === 'executions' && (
            <>
              {/* Execution Log Form Section */}
{/*               <section className="card">
                <h2>Create New Execution Log</h2>
                <ExecutionLogForm onSubmit={createExecutionLog} />
              </section> */}

              {/* Execution Log List Section */}
              <section className="card">
                <div className="logs-header">
                  <h2>Execution Logs</h2>
                  <div className="controls">
                    <button onClick={fetchExecutionLogs} className="btn btn-secondary">
                      🔄 Refresh
                    </button>
                    <button onClick={clearAllExecutionLogs} className="btn btn-danger">
                      🗑️ Clear All
                    </button>
                  </div>
                </div>

                {error && <div className="error-message">{error}</div>}
                {executionLoading ? (
                  <div className="loading">Loading Execution Logs...</div>
                ) : (
                  <ExecutionLogList logs={executionLogs} onDelete={deleteExecutionLog} />
                )}
              </section>
            </>
          )}

          {/* Export Logs Tab */}
          {activeTab === 'exports' && (
            <>
              {/* Export Log List Section */}
              <section className="card">
                <div className="logs-header">
                  <h2>Export Logs</h2>
                  <div className="controls">
                    <button onClick={fetchExportLogs} className="btn btn-secondary">
                      🔄 Refresh
                    </button>
                    <button onClick={clearAllExportLogs} className="btn btn-danger">
                      🗑️ Clear All
                    </button>
                  </div>
                </div>

                {error && <div className="error-message">{error}</div>}
                {exportLoading ? (
                  <div className="loading">Loading Export Logs...</div>
                ) : (
                  <ExportLogList logs={exportLogs} onDelete={deleteExportLog} />
                )}
              </section>
            </>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;
