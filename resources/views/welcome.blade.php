<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vistoria Veicular - Inspeção Profissional</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
        
        * { font-family: 'Inter', sans-serif; }
        
        /* Animações fluidas */
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }
        
        @keyframes gradient-shift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        
        @keyframes slide-in-right {
            from { opacity: 0; transform: translateX(30px); }
            to { opacity: 1; transform: translateX(0); }
        }
        
        @keyframes slide-in-left {
            from { opacity: 0; transform: translateX(-30px); }
            to { opacity: 1; transform: translateX(0); }
        }
        
        .float { animation: float 3s ease-in-out infinite; }
        .gradient-bg { 
            background: linear-gradient(-45deg, #0b5db3, #0d7bc9, #1fa2d1, #0b5db3);
            background-size: 300% 300%;
            animation: gradient-shift 8s ease infinite;
        }
        .slide-right { animation: slide-in-right 0.6s ease-out; }
        .slide-left { animation: slide-in-left 0.6s ease-out; }
        
        /* Glass morphism */
        .glass {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        /* Hover effects */
        .hover-lift {
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .hover-lift:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(11, 93, 179, 0.3);
        }
        
        /* Feature cards */
        .feature-card {
            transition: all 0.3s ease;
        }
        .feature-card:hover {
            transform: translateY(-5px);
        }
    </style>
</head>
<body class="bg-white">
    
    <!-- Navigation -->
    <nav class="fixed w-full top-0 z-50 gradient-bg text-white shadow-lg">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-16">
                <div class="flex items-center gap-2">
                    <img src="{{ asset('logo.png') }}" alt="Logo" class="h-8 w-auto">
                    <span class="text-xl font-bold">Vistoria</span>
                </div>
                <div class="hidden md:flex gap-8">
                    <a href="#features" class="hover:text-blue-100 transition">Recursos</a>
                    <a href="#benefits" class="hover:text-blue-100 transition">Benefícios</a>
                    <a href="#contact" class="hover:text-blue-100 transition">Contato</a>
                </div>
                <div class="flex gap-3">
                    @auth
                        <a href="{{ route('dashboard') }}" class="px-4 py-2 bg-white text-blue-600 rounded-lg font-semibold hover:bg-blue-50 transition">
                            Painel
                        </a>
                    @else
                        <a href="{{ route('login') }}" class="px-4 py-2 hover:bg-white hover:text-blue-600 transition rounded-lg">
                            Login
                        </a>
                        <a href="{{ route('register') }}" class="px-4 py-2 bg-white text-blue-600 rounded-lg font-semibold hover:bg-blue-50 transition">
                            Cadastro
                        </a>
                    @endauth
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="gradient-bg text-white pt-32 pb-20 relative overflow-hidden">
        <div class="absolute top-0 right-0 w-96 h-96 bg-blue-300 rounded-full mix-blend-multiply filter blur-3xl opacity-20 float"></div>
        <div class="absolute bottom-0 left-0 w-96 h-96 bg-blue-200 rounded-full mix-blend-multiply filter blur-3xl opacity-20 float" style="animation-delay: 2s;"></div>
        
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <div class="grid md:grid-cols-2 gap-12 items-center">
                <div class="slide-left">
                    <h1 class="text-5xl md:text-6xl font-bold mb-6 leading-tight">
                        Inspeção Veicular <span class="text-blue-200">Profissional</span>
                    </h1>
                    <p class="text-xl text-blue-100 mb-8 leading-relaxed">
                        Sistema moderno e intuitivo para laudos de vistoria veicular com precisão e segurança.
                    </p>
                    <div class="flex flex-col sm:flex-row gap-4">
                        @auth
                            <a href="{{ route('dashboard') }}" class="px-8 py-3 bg-white text-blue-600 rounded-lg font-bold hover:bg-blue-50 transition text-center hover-lift">
                                Acessar Sistema
                            </a>
                        @else
                            <a href="{{ route('register') }}" class="px-8 py-3 bg-white text-blue-600 rounded-lg font-bold hover:bg-blue-50 transition text-center hover-lift">
                                Começar Agora
                            </a>
                            <a href="{{ route('login') }}" class="px-8 py-3 border-2 border-white text-white rounded-lg font-bold hover:bg-white hover:text-blue-600 transition text-center hover-lift">
                                Já tem Conta
                            </a>
                        @endauth
                    </div>
                </div>
                <div class="slide-right hidden md:block">
                    <div class="relative">
                        <div class="absolute inset-0 bg-gradient-to-r from-blue-400 to-blue-600 rounded-2xl blur-2xl opacity-20"></div>
                        <img src="{{ asset('logo.png') }}" alt="Vistoria" class="relative w-full h-auto float">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="py-20 bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16">
                <h2 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">Recursos Poderosos</h2>
                <p class="text-xl text-gray-600">Tudo que você precisa para inspeções profissionais</p>
            </div>
            
            <div class="grid md:grid-cols-3 gap-8">
                <!-- Feature 1 -->
                <div class="feature-card glass rounded-2xl p-8 hover-lift">
                    <div class="w-14 h-14 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Laudos Rápidos</h3>
                    <p class="text-gray-600">Gere laudos profissionais em minutos com nossa interface intuitiva.</p>
                </div>

                <!-- Feature 2 -->
                <div class="feature-card glass rounded-2xl p-8 hover-lift">
                    <div class="w-14 h-14 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Galeria de Fotos</h3>
                    <p class="text-gray-600">Integre fotos de alta qualidade com anotações e observações.</p>
                </div>

                <!-- Feature 3 -->
                <div class="feature-card glass rounded-2xl p-8 hover-lift">
                    <div class="w-14 h-14 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Análise Completa</h3>
                    <p class="text-gray-600">Sistema abrangente de análise estrutural e mecânica de veículos.</p>
                </div>

                <!-- Feature 4 -->
                <div class="feature-card glass rounded-2xl p-8 hover-lift">
                    <div class="w-14 h-14 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Seguro e Confiável</h3>
                    <p class="text-gray-600">Seus dados protegidos com encriptação e backup automático.</p>
                </div>

                <!-- Feature 5 -->
                <div class="feature-card glass rounded-2xl p-8 hover-lift">
                    <div class="w-14 h-14 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Rápido e Eficiente</h3>
                    <p class="text-gray-600">Otimizado para máxima performance e melhor experiência do usuário.</p>
                </div>

                <!-- Feature 6 -->
                <div class="feature-card glass rounded-2xl p-8 hover-lift">
                    <div class="w-14 h-14 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Personalizável</h3>
                    <p class="text-gray-600">Adapte o sistema às suas necessidades e processos específicos.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section id="benefits" class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid md:grid-cols-2 gap-12 items-center">
                <div>
                    <h2 class="text-4xl font-bold text-gray-900 mb-8">Por que escolher o Vistoria?</h2>
                    <div class="space-y-6">
                        <div class="flex gap-4">
                            <div class="flex-shrink-0">
                                <div class="flex items-center justify-center h-12 w-12 rounded-md bg-blue-600 text-white">
                                    ✓
                                </div>
                            </div>
                            <div>
                                <h3 class="text-lg font-bold text-gray-900">Interface Intuitiva</h3>
                                <p class="text-gray-600">Design moderno e fácil de usar, sem necessidade de treinamento complexo.</p>
                            </div>
                        </div>
                        <div class="flex gap-4">
                            <div class="flex-shrink-0">
                                <div class="flex items-center justify-center h-12 w-12 rounded-md bg-blue-600 text-white">
                                    ✓
                                </div>
                            </div>
                            <div>
                                <h3 class="text-lg font-bold text-gray-900">Maior Produtividade</h3>
                                <p class="text-gray-600">Reduza o tempo de elaboração de laudos em até 70%.</p>
                            </div>
                        </div>
                        <div class="flex gap-4">
                            <div class="flex-shrink-0">
                                <div class="flex items-center justify-center h-12 w-12 rounded-md bg-blue-600 text-white">
                                    ✓
                                </div>
                            </div>
                            <div>
                                <h3 class="text-lg font-bold text-gray-900">Suporte 24/7</h3>
                                <p class="text-gray-600">Equipe dedicada pronta para ajudar quando você precisar.</p>
                            </div>
                        </div>
                        <div class="flex gap-4">
                            <div class="flex-shrink-0">
                                <div class="flex items-center justify-center h-12 w-12 rounded-md bg-blue-600 text-white">
                                    ✓
                                </div>
                            </div>
                            <div>
                                <h3 class="text-lg font-bold text-gray-900">Atualizações Contínuas</h3>
                                <p class="text-gray-600">Novos recursos e melhorias adicionados regularmente.</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="hidden md:block">
                    <div class="relative">
                        <div class="absolute inset-0 bg-gradient-to-r from-blue-400 to-blue-600 rounded-2xl blur-2xl opacity-20"></div>
                        <div class="glass rounded-2xl p-8 relative">
                            <div class="space-y-4">
                                <div class="h-24 bg-gradient-to-r from-blue-100 to-blue-50 rounded-lg"></div>
                                <div class="h-32 bg-gradient-to-r from-blue-100 to-blue-50 rounded-lg"></div>
                                <div class="h-20 bg-gradient-to-r from-blue-100 to-blue-50 rounded-lg"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="gradient-bg text-white py-20">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 class="text-4xl md:text-5xl font-bold mb-6">Pronto para começar?</h2>
            <p class="text-xl text-blue-100 mb-8">Junte-se a centenas de profissionais que confiam no Vistoria.</p>
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
                @auth
                    <a href="{{ route('dashboard') }}" class="px-8 py-3 bg-white text-blue-600 rounded-lg font-bold hover:bg-blue-50 transition hover-lift">
                        Acessar Painel
                    </a>
                @else
                    <a href="{{ route('register') }}" class="px-8 py-3 bg-white text-blue-600 rounded-lg font-bold hover:bg-blue-50 transition hover-lift">
                        Cadastre-se Grátis
                    </a>
                    <a href="{{ route('login') }}" class="px-8 py-3 border-2 border-white text-white rounded-lg font-bold hover:bg-white hover:text-blue-600 transition hover-lift">
                        Fazer Login
                    </a>
                @endauth
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-gray-900 text-white py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid md:grid-cols-4 gap-8 mb-8">
                <div>
                    <h3 class="font-bold mb-4">Vistoria</h3>
                    <p class="text-gray-400">Sistema profissional de inspeção veicular.</p>
                </div>
                <div>
                    <h3 class="font-bold mb-4">Produto</h3>
                    <ul class="space-y-2 text-gray-400">
                        <li><a href="#features" class="hover:text-white transition">Recursos</a></li>
                        <li><a href="#benefits" class="hover:text-white transition">Benefícios</a></li>
                        <li><a href="#" class="hover:text-white transition">Preços</a></li>
                    </ul>
                </div>
                <div>
                    <h3 class="font-bold mb-4">Empresa</h3>
                    <ul class="space-y-2 text-gray-400">
                        <li><a href="#" class="hover:text-white transition">Sobre</a></li>
                        <li><a href="#" class="hover:text-white transition">Blog</a></li>
                        <li><a href="#" class="hover:text-white transition">Carreiras</a></li>
                    </ul>
                </div>
                <div>
                    <h3 class="font-bold mb-4">Legal</h3>
                    <ul class="space-y-2 text-gray-400">
                        <li><a href="#" class="hover:text-white transition">Privacidade</a></li>
                        <li><a href="#" class="hover:text-white transition">Termos</a></li>
                        <li><a href="#" class="hover:text-white transition">Contato</a></li>
                    </ul>
                </div>
            </div>
            <div class="border-t border-gray-700 pt-8 text-center text-gray-400">
                <p>&copy; 2025 Vistoria. Todos os direitos reservados.</p>
            </div>
        </div>
    </footer>

</body>
</html>