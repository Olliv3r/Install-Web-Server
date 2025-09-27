<!DOCTYPE html>
<html>
<head>
  <title>Servidor Termux</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <style>
      body { 
          font-family: Arial, sans-serif; 
          margin: 40px; 
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
      }
      .container {
          max-width: 1000px;
          margin: 0 auto;
          background: white;
          padding: 30px;
          border-radius: 15px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2);
      }
      h1 { 
          color: #333; 
          text-align: center;
          margin-bottom: 30px;
      }
      .dashboard {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 20px;
          margin: 30px 0;
      }
      .card {
          background: #f8f9fa;
          padding: 20px;
          border-radius: 10px;
          border-left: 5px solid;
      }
      .card.servidor { border-color: #28a745; }
      .card.projetos { border-color: #007bff; }
      .card.ferramentas { border-color: #ff6b6b; }
      .card.mariadb { border-color: #c24d4d; }
      
      .projeto-item, .ferramenta-item {
          padding: 10px;
          margin: 8px 0;
          background: white;
          border-radius: 5px;
          transition: transform 0.2s;
      }
      .projeto-item:hover, .ferramenta-item:hover {
          transform: translateX(5px);
      }
      .projeto-item a, .ferramenta-item a {
          text-decoration: none;
          color: #333;
          font-weight: bold;
          display: block;
      }
      .projeto-item a:hover, .ferramenta-item a:hover {
          color: #007bff;
      }
      .info-item {
          display: flex;
          justify-content: space-between;
          padding: 5px 0;
          border-bottom: 1px solid #eee;
      }
      .badge {
          background: #007bff;
          color: white;
          padding: 2px 8px;
          border-radius: 12px;
          font-size: 12px;
      }
      .mariadb-btn {
          background: linear-gradient(45deg, #c24d4d, #d46a6a);
          color: white;
          padding: 15px;
          text-align: center;
          border-radius: 8px;
          text-decoration: none;
          display: block;
          margin: 10px 0;
          font-weight: bold;
          transition: transform 0.3s;
      }
      .mariadb-btn:hover {
          transform: scale(1.05);
          color: white;
      }
      .stats {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
          gap: 15px;
          margin: 20px 0;
      }
      .stat-card {
          background: #e7f3ff;
          padding: 15px;
          border-radius: 8px;
          text-align: center;
      }
      .termux-commands {
          background: #2d3748;
          color: #fff;
          padding: 15px;
          border-radius: 8px;
          font-family: monospace;
          font-size: 14px;
          margin: 10px 0;
      }
      .command {
          color: #68d391;
      }
      .status-online { color: #28a745; font-weight: bold; }
      .status-offline { color: #dc3545; font-weight: bold; }
      @media (max-width: 768px) {
          .dashboard {
              grid-template-columns: 1fr;
          }
          body {
              margin: 20px;
          }
      }
  </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Painel do Servidor Termux</h1>
        
        <!-- Estatísticas Rápidas -->
        <div class="stats">
            <div class="stat-card">
                <strong>PHP</strong><br>
                <?php echo phpversion(); ?>
            </div>
            <div class="stat-card">
                <strong>Servidor</strong><br>
                <?php echo explode(" ", $_SERVER["SERVER_SOFTWARE"])[0]; ?>
            </div>
            <div class="stat-card">
                <strong>MariaDB</strong><br>
                <?php
                function testMariaDBConnection(
                  $host = "127.0.0.1",
                  $user = "root",
                  $pass = ""
                ) {
                  try {
                    $pdo = new PDO("mysql:host=$host", $user, $pass, [
                      PDO::ATTR_TIMEOUT => 2,
                      PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    ]);
                    $version = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);
                    return [
                      "status" => "online",
                      "version" => explode("-", $version)[0],
                    ];
                  } catch (Exception $e) {
                    return ["status" => "offline", "error" => $e->getMessage()];
                  }
                }

                $mariadb_status = testMariaDBConnection();
                if ($mariadb_status["status"] === "online") {
                  echo $mariadb_status["version"];
                } else {
                  // Tentar com localhost também
                  $mariadb_status = testMariaDBConnection("localhost");
                  if ($mariadb_status["status"] === "online") {
                    echo $mariadb_status["version"];
                  } else {
                    echo "Offline";
                  }
                }
                ?>
            </div>
            <div class="stat-card">
                <strong>Data/Hora</strong><br>
                <?php echo date("d/m/Y H:i:s"); ?>
            </div>
        </div>

        <div class="dashboard">
            <!-- Card de Projetos -->
            <div class="card projetos">
                <h2>📁 Projetos de Estudo</h2>
                <?php
                $itens = glob("*", GLOB_ONLYDIR);
                $projetos = array_filter($itens, function ($item) {
                  return !in_array($item, [".", ".."]);
                });
                natcasesort($projetos);
                ?>
                
                <?php if (empty($projetos)): ?>
                    <p>Nenhum projeto encontrado.</p>
                <?php else: ?>
                    <?php foreach ($projetos as $projeto): ?>
                        <div class="projeto-item">
                            <a href="/<?php echo $projeto; ?>/" target="_blank">
                                📂 <?php echo htmlspecialchars($projeto); ?>
                            </a>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
                <p><em>Total: <?php echo count($projetos); ?> projetos</em></p>
            </div>

            <!-- Card do Servidor -->
            <div class="card servidor">
                <h2>⚙️ Informações do Servidor</h2>
                <div class="info-item">
                    <span>PHP Version:</span>
                    <span class="badge"><?php echo phpversion(); ?></span>
                </div>
                <div class="info-item">
                    <span>Software:</span>
                    <span><?php echo $_SERVER["SERVER_SOFTWARE"]; ?></span>
                </div>
                <div class="info-item">
                    <span>MariaDB:</span>
                    <span>
                        <?php
                        $mariadb_status = testMariaDBConnection();
                        if ($mariadb_status["status"] === "online") {
                          echo '<span class="status-online">✅ Online - v' .
                            $mariadb_status["version"] .
                            "</span>";
                        } else {
                          // Tentar com localhost
                          $mariadb_status = testMariaDBConnection("localhost");
                          if ($mariadb_status["status"] === "online") {
                            echo '<span class="status-online">✅ Online (localhost) - v' .
                              $mariadb_status["version"] .
                              "</span>";
                          } else {
                            echo '<span class="status-offline">❌ Offline</span>';
                          }
                        }
                        ?>
                    </span>
                </div>
                <div class="info-item">
                    <span>Document Root:</span>
                    <span><?php echo $_SERVER["DOCUMENT_ROOT"]; ?></span>
                </div>
            </div>

            <!-- Card do MariaDB -->
            <div class="card mariadb">
                <h2>🗃️ MariaDB (Termux)</h2>
                <p>Gerenciador do Banco de Dados</p>
                
                <?php
                // Testar conexão com MariaDB
                $mariadb_status = testMariaDBConnection();
                if ($mariadb_status["status"] === "online") {
                  $status_text = "✅ Online (127.0.0.1)";
                  $status_color = "green";
                  $version_info = "v" . $mariadb_status["version"];
                } else {
                  // Tentar com localhost
                  $mariadb_status = testMariaDBConnection("localhost");
                  if ($mariadb_status["status"] === "online") {
                    $status_text = "✅ Online (localhost)";
                    $status_color = "green";
                    $version_info = "v" . $mariadb_status["version"];
                  } else {
                    $status_text = "❌ Offline";
                    $status_color = "red";
                    $version_info = "Serviço não respondendo";
                  }
                }
                ?>
                
                <div style="text-align: center; margin: 15px 0;">
                    <p><strong>Status:</strong> <span style="color: <?php echo $status_color; ?>"><?php echo $status_text; ?></span></p>
                    <p><strong>Versão:</strong> <?php echo $version_info; ?></p>
                </div>

                <a href="/phpmyadmin/" class="mariadb-btn" target="_blank">
                    🔗 Acessar phpMyAdmin
                </a>
                
                <div class="termux-commands">
                    <strong>Comandos Termux (MariaDB):</strong><br>
                    <span class="command">pkg install mariadb</span> - Instalar<br>
                    <span class="command">mariadbd-safe &</span> - Iniciar serviço<br>
                    <span class="command">mysql -h 127.0.0.1 -u root</span> - Conectar<br>
                    <span class="command">mysql_secure_installation</span> - Segurança<br>
                    <span class="command">pkill mariadbd</span> - Parar serviço
                </div>

                <div style="margin-top: 15px; font-size: 12px; color: #666;">
                    <strong>Hosts testados:</strong> 127.0.0.1, localhost
                </div>
            </div>

            <!-- Card de Ferramentas -->
            <div class="card ferramentas">
                <h2>🛠️ Ferramentas Úteis</h2>
                
                <div class="ferramenta-item">
                    <a href="/phpinfo.php" target="_blank">
                        ℹ️ PHP Info
                    </a>
                </div>
                
                <div class="ferramenta-item">
                    <a href="/test_db.php" target="_blank">
                        🧪 Testar Conexão MariaDB
                    </a>
                </div>
                
                <div class="ferramenta-item">
                    <a href="/adminer.php" target="_blank">
                        🗄️ Adminer (Alternativo)
                    </a>
                </div>
                
                <div class="ferramenta-item">
                    <a href="/status_mariadb.php" target="_blank">
                        📊 Status Detalhado MariaDB
                    </a>
                </div>
            </div>
        </div>

        <!-- Comandos Úteis Termux -->
        <div class="card" style="grid-column: 1 / -1; margin-top: 20px;">
            <h2>🐧 Comandos Úteis - Termux</h2>
            <div class="termux-commands">
                <span class="command">pkg update && pkg upgrade</span> - Atualizar pacotes<br>
                <span class="command">pkg install php apache2 mariadb</span> - Instalar stack<br>
                <span class="command">mariadbd-safe &</span> - Iniciar MariaDB<br>
                <span class="command">mysql -h 127.0.0.1 -u root</span> - Conectar ao MariaDB<br>
                <span class="command">apachectl start</span> - Iniciar Apache<br>
                <span class="command">ps aux | grep mariadbd</span> - Ver processos MariaDB
            </div>
        </div>

        <!-- Rodapé -->
        <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #666;">
            <p>🚀 Servidor Termux com MariaDB • <?php echo date(
              "Y"
            ); ?> • Desenvolvimento Local</p>
        </div>
    </div>

    <!-- Script para criar arquivos úteis automaticamente -->
    <?php
    // Criar arquivo de teste de conexão MariaDB
    $testDbFile = "test_db.php";
    if (!file_exists($testDbFile)) {
      $testDbContent = '<?php
// Teste de Conexão MariaDB (Termux)
echo "<h2>🧪 Teste de Conexão MariaDB</h2>";

function testMariaDBHost($host) {
    echo "<h3>Testando conexão com: <code>$host</code></h3>";
    try {
        $pdo = new PDO("mysql:host=$host", "root", "", [
            PDO::ATTR_TIMEOUT => 3,
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
        $version = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);
        echo "<p style=\"color: green;\">✅ Conexão bem-sucedida com <strong>$host</strong></p>";
        echo "<p><strong>Versão:</strong> " . htmlspecialchars($version) . "</p>";
        
        // Listar bancos de dados
        $databases = $pdo->query("SHOW DATABASES")->fetchAll(PDO::FETCH_COLUMN);
        echo "<h4>📊 Bancos de Dados:</h4>";
        echo "<ul>";
        foreach ($databases as $db) {
            echo "<li>" . htmlspecialchars($db) . "</li>";
        }
        echo "</ul>";
        
        return true;
    } catch (PDOException $e) {
        echo "<p style=\"color: red;\">❌ Falha na conexão com <strong>$host</strong>: " . $e->getMessage() . "</p>";
        return false;
    }
}

// Testar ambos os hosts
$hosts = ["127.0.0.1", "localhost"];
$any_success = false;

foreach ($hosts as $host) {
    if (testMariaDBHost($host)) {
        $any_success = true;
    }
    echo "<hr>";
}

if (!$any_success) {
    echo "<div style=\"background: #f8d7da; padding: 15px; border-radius: 5px;\">";
    echo "<h3>🔧 Solução para Termux:</h3>";
    echo "<ol>";
    echo "<li>Verificar se MariaDB está rodando: <code>ps aux | grep mariadbd</code></li>";
    echo "<li>Iniciar serviço: <code>mariadbd-safe &</code></li>";
    echo "<li>Testar conexão: <code>mysql -h 127.0.0.1 -u root</code></li>";
    echo "</ol>";
    echo "</div>";
}
?>';
      file_put_contents($testDbFile, $testDbContent);
    }

    // Criar arquivo de status detalhado
    $statusFile = "status_mariadb.php";
    if (!file_exists($statusFile)) {
      $statusContent = '<?php
echo "<h2>📊 Status Detalhado do MariaDB</h2>";

function getMariaDBStatus() {
    $output = [];
    $return_code = 0;
    
    // Verificar processos
    exec("ps aux | grep mariadbd", $output, $return_code);
    
    echo "<h3>🔍 Processos MariaDB:</h3>";
    if (!empty($output)) {
        echo "<pre style=\"background: #f4f4f4; padding: 10px; border-radius: 5px;\">";
        foreach ($output as $line) {
            if (strpos($line, "grep") === false) {
                echo htmlspecialchars($line) . "\n";
            }
        }
        echo "</pre>";
    } else {
        echo "<p style=\"color: red;\">❌ Nenhum processo MariaDB encontrado</p>";
    }
    
    // Testar conexões
    $hosts = ["127.0.0.1", "localhost"];
    echo "<h3>🌐 Teste de Conexões:</h3>";
    
    foreach ($hosts as $host) {
        try {
            $pdo = new PDO("mysql:host=$host", "root", "", [
                PDO::ATTR_TIMEOUT => 2,
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
            ]);
            $version = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);
            echo "<p style=\"color: green;\">✅ <strong>$host</strong>: Conectado - " . htmlspecialchars($version) . "</p>";
        } catch (Exception $e) {
            echo "<p style=\"color: red;\">❌ <strong>$host</strong>: " . $e->getMessage() . "</p>";
        }
    }
}

getMariaDBStatus();
?>';
      file_put_contents($statusFile, $statusContent);
    }

    // Criar outros arquivos se necessário
    $files_to_create = [
      "phpinfo.php" => "<?php phpinfo(); ?>",
      "adminer.php" => '<?php
echo "<h2>🗄️ Adminer - Gerenciador de Banco de Dados</h2>";
echo "<p>Download: <a href=\"https://www.adminer.org/\" target=\"_blank\">adminer.org</a></p>";
echo "<p>Substitua este arquivo pelo Adminer.</p>";
?>',
    ];

    foreach ($files_to_create as $filename => $content) {
      if (!file_exists($filename)) {
        file_put_contents($filename, $content);
      }
    }
    ?>
</body>
</html>