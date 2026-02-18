<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Consulta de Chassi Parcial</title>
    <style>
        /* --- ESTILOS MODIFICADOS PARA CENTRALIZAÇÃO E LAYOUT --- */
        html, body {
            height: 100%; /* Garante que a página ocupe toda a altura da tela */
        }
        body {
            display: flex; /* Ativa o modo Flexbox */
            justify-content: center; /* Centraliza o conteúdo na horizontal */
            align-items: center;   /* Centraliza o conteúdo na vertical */
            margin: 0; /* Remove a margem padrão do navegador */
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
        }
        .container {
            background-color: #fff;
            padding: 40px; /* Aumentei o espaçamento interno */
            border-radius: 10px; /* Bordas um pouco mais arredondadas */
            box-shadow: 0 4px 15px rgba(0,0,0,0.1); /* Sombra mais destacada */
            max-width: 600px; /* Largura máxima do container */
            width: 90%; /* Garante que ele não ocupe a tela toda em telas pequenas */
            text-align: center; /* Centraliza o texto e a logo dentro do container */
        }
        
        /* --- ESTILO PARA A LOGO --- */
        .logo {
            max-width: 250px; /* Largura máxima da logo */
            margin-bottom: 25px; /* Espaço entre a logo e o título */
        }

        /* --- ESTILOS DOS OUTROS ELEMENTOS (sem grandes mudanças) --- */
        h2 {
            margin-bottom: 30px; /* Aumentei o espaço abaixo do título */
        }
        form {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        form input[type="text"] {
            flex-grow: 1;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            text-align: left; /* Alinha o texto do input à esquerda */
        }
        form button {
            padding: 10px 20px;
            border: 1px solid #ccc;
            border-radius: 4px;
            background-color: #007BFF;
            color: white;
            cursor: pointer;
        }
        .resultados {
            margin-top: 20px;
            border-top: 1px solid #eee;
            padding-top: 20px;
            text-align: left; /* Alinha o texto dos resultados à esquerda */
        }
        .item-resultado { background-color: #e9ecef; padding: 15px; border-radius: 4px; margin-bottom: 10px; line-height: 1.6; }
        .item-resultado strong { color: #0056b3; display: inline-block; width: 90px; }
        .erro { color: #dc3545; text-align: center; font-weight: bold; background-color: #f8d7da; padding: 10px; border: 1px solid #f5c6cb; border-radius: 4px; }
        /* Adicionado .aguarde junto com .info */
        .info, .aguarde { color: #0c5460; text-align: center; background-color: #d1ecf1; padding: 10px; border: 1px solid #bee5eb; border-radius: 4px; word-break: break-all; }
        .debug { background-color: #1d1d1d; color: #00ff00; padding: 15px; border-radius: 5px; font-family: 'Courier New', Courier, monospace; white-space: pre-wrap; margin-bottom: 15px; text-align: left; }
    </style>
</head>
<body>

<div class="container">

    <img src="https://autocredcarcloud.com.br/logo.png" alt="Logo da Empresa" class="logo">

    <h2>Consulta de Chassi Parcial</h2>

    <form action="consulta.php" method="post" id="consulta-form">
        <input type="text" name="chassi_param" placeholder="Digite o chassi para consultar..." required>
        <button type="submit">Consultar</button>
    </form>
    
    <div id="mensagem-aguarde" class="aguarde" style="display: none; margin-top: 15px;">
        ⏳ Aguarde, a busca pode demorar um pouco devido ao número de resultados...
    </div>


    <div class="resultados">
        <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST" && !empty($_POST['chassi_param'])) {

            $chassi_input = trim($_POST['chassi_param']);
            
            if (strlen($chassi_input) < 8) {
                echo "<p class='erro'>Por favor, informe no mínimo 8 caracteres para a pesquisa.</p>";
            } else {
                // Se a validação passar, continua para a consulta e depuração
                $url_base = "https://bin.autocredcar.com.br/ApiAutoCredCar/Bases/AgregadosBuscaChassi";
                $cliente = "TesteAgregados";
                $chave_key = "VG9rZW5UZXN0ZUFncmVnYWRvc0V4Y2x1aXIxMkFjZXNzbzk5";
                $parametro_chassi = urlencode($chassi_input);

                $url_completa = "{$url_base}?chassi={$parametro_chassi}&cliente={$cliente}&chavekey={$chave_key}";

                $ch = curl_init();
                curl_setopt($ch, CURLOPT_URL, $url_completa);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                // Timeout ajustado para um valor padrão de 2 minutos.
                curl_setopt($ch, CURLOPT_TIMEOUT, 120);

                $resposta_api = curl_exec($ch);
                
                echo "<div class='debug'><strong>INÍCIO DA RESPOSTA CRUA DA API</strong><br><br>";
                echo "Tipo da variável: " . gettype($resposta_api) . "<br>";
                echo "Conteúdo:<br>";
                print_r($resposta_api);
                echo "<br><br><strong>FIM DA RESPOSTA CRUA DA API</strong></div>";

                $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                
                if (curl_errno($ch) || $http_code >= 400) {
                     echo "<p class='erro'>Erro ao consultar o serviço. ";
                     if (curl_errno($ch)) {
                         echo "Erro cURL: " . curl_error($ch);
                     } else {
                         echo "A API retornou um erro HTTP " . $http_code . ".";
                     }
                     echo "</p>";
                } else {
                    libxml_use_internal_errors(true);
                    $xml = simplexml_load_string($resposta_api);

                    if ($xml === false || count($xml->string) == 0) {
                        echo "<p class='erro'>Falha ao processar o XML ou a resposta da API está vazia. Verifique o chassi e tente novamente.</p>";
                    } else {
                        $dados_veiculo = [];
                        $items = $xml->string;
                        for ($i = 0; $i < count($items); $i += 2) {
                            if (isset($items[$i]) && isset($items[$i + 1])) {
                                $chave = (string) $items[$i];
                                $valor = (string) $items[$i + 1];
                                $dados_veiculo[$chave] = $valor;
                            }
                        }

                        echo "<h3>Resultado da Consulta:</h3>";
                        echo "<div class='item-resultado'>";
                        foreach ($dados_veiculo as $campo => $valor) {
                            echo "<strong>" . htmlspecialchars($campo) . ":</strong> " . htmlspecialchars($valor) . "<br>";
                        }
                        echo "</div>";
                    }
                }
                curl_close($ch);
            }
        }
        ?>
    </div>
</div>

<script>
    const consultaForm = document.getElementById('consulta-form');
    const mensagemAguarde = document.getElementById('mensagem-aguarde');

    consultaForm.addEventListener('submit', function() {
        // Remove a mensagem de 'Consultando API' se ela existir de uma busca anterior
        const infoMsg = document.querySelector('.info');
        if(infoMsg) {
            infoMsg.style.display = 'none';
        }
        // Mostra a mensagem de "aguarde"
        mensagemAguarde.style.display = 'block';
    });
</script>

</body>
</html>