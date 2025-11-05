<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Vistoria Veicular Online - Aprov Fácil</title>
    
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />
    
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="bg-gray-100 font-sans antialiased text-gray-900">

    <nav class="bg-white shadow-md">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <a href="/" class="text-2xl font-bold text-blue-600">Aprov Fácil</a>
                </div>
                <div class="flex items-center space-x-4">
                    @auth
                        <a href="{{ url('/dashboard') }}" class="font-semibold text-gray-600 hover:text-gray-900">Dashboard</a>
                    @else
                        <a href="{{ route('login') }}" class="font-semibold text-gray-600 hover:text-gray-900">Entrar</a>
                        <a href="{{ route('register') }}" class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 ml-4">Registrar</a>
                    @endauth
                </div>
            </div>
        </div>
    </nav>

    <header class="bg-blue-600 text-white py-20 text-center">
        <div class="container mx-auto px-4">
            <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight">
                Vistoria Online de Veículos
            </h1>
            <p class="mt-4 text-xl max-w-3xl mx-auto">
                Faça o laudo do seu veículo de forma rápida, segura e 100% digital, sem sair de casa.
            </p>
            <div class="mt-10">
                <a href="{{ route('register') }}" class="bg-white text-blue-600 hover:bg-gray-200 font-bold py-3 px-8 rounded-full text-lg shadow-lg transition duration-300">
                    Comece Agora
                </a>
            </div>
        </div>
    </header>

    <main class="container mx-auto px-4 py-16">

        <section class="mb-16">
            <h2 class="text-3xl font-bold text-center mb-10">Por que escolher o Aprov Fácil?</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
                <div class="bg-white p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300">
                    <div class="text-blue-500 mb-4">
                        <svg class="h-12 w-12 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                    </div>
                    <h3 class="text-xl font-semibold mb-2">Agilidade</h3>
                    <p class="text-gray-600">Laudo aprovado em minutos, sem filas ou burocracia.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300">
                    <div class="text-blue-500 mb-4">
                        <svg class="h-12 w-12 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                    </div>
                    <h3 class="text-xl font-semibold mb-2">Praticidade</h3>
                    <p class="text-gray-600">Faça tudo pelo seu celular, de onde estiver.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300">
                    <div class="text-blue-500 mb-4">
                        <svg class="h-12 w-12 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <h3 class="text-xl font-semibold mb-2">Segurança</h3>
                    <p class="text-gray-600">Nossa equipe de analistas garante a validade do seu laudo.</p>
                </div>
            </div>
        </section>

        <section class="mb-16">
            <h2 class="text-3xl font-bold text-center mb-10">Passo a Passo Simples</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <div class="bg-white p-6 rounded-lg shadow-md text-center">
                    <div class="text-blue-600 text-5xl font-bold mb-4">1</div>
                    <h3 class="text-xl font-semibold mb-2">Pague a Vistoria</h3>
                    <p class="text-gray-600">Faça o pagamento seguro para liberar o acesso ao formulário.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-md text-center">
                    <div class="text-blue-600 text-5xl font-bold mb-4">2</div>
                    <h3 class="text-xl font-semibold mb-2">Envie os Dados</h3>
                    <p class="text-gray-600">Tire fotos do seu veículo e preencha os dados em nosso sistema.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-md text-center">
                    <div class="text-blue-600 text-5xl font-bold mb-4">3</div>
                    <h3 class="text-xl font-semibold mb-2">Receba o Laudo</h3>
                    <p class="text-gray-600">Nossos analistas emitem o laudo, e você o recebe em sua conta.</p>
                </div>
            </div>
        </section>

        <section class="bg-gray-200 rounded-lg p-10 text-center">
            <h2 class="text-3xl font-bold mb-4">Preço</h2>
            <p class="text-5xl font-bold text-blue-600">R$ 59,90</p>
            <p class="mt-2 text-gray-600">Pagamento único por vistoria.</p>
            <div class="mt-6">
                <a href="{{ route('register') }}" class="inline-flex items-center justify-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 transition duration-300">
                    Comece Sua Vistoria
                </a>
            </div>
        </section>

    </main>

    <footer class="bg-gray-800 text-gray-400 py-8 text-center">
        <p>&copy; {{ date('Y') }} Vistoria Online. Todos os direitos reservados.</p>
    </footer>

</body>
</html>