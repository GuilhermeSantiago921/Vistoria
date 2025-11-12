<nav x-data="{ open: false }" class="bg-gradient-to-r from-blue-700 to-blue-900 text-white shadow-xl sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
            <div class="flex items-center gap-8">
                <div class="shrink-0 flex items-center">
                    <a href="{{ route('dashboard') }}" class="flex items-center gap-3 font-bold text-2xl text-white hover:opacity-90 transition">
                        <img src="{{ asset('logo.png') }}" alt="Logo" class="h-10 w-10">
                        <span>Vistoria</span>
                    </a>
                </div>

                {{-- LINKS DE NAVEGAÇÃO PRINCIPAL (Desktop) --}}
                <div class="hidden space-x-1 sm:-my-px sm:ms-10 sm:flex">
                    
                    {{-- Link Básico para o Dashboard --}}
                    <a href="{{ route('dashboard') }}" class="px-4 py-2 rounded-lg text-sm font-bold hover:bg-blue-600 transition {{ request()->routeIs('dashboard') ? 'bg-blue-600' : '' }}">
                        📊 Painel
                    </a>

                    {{-- Link CONDICIONAL para ADMIN --}}
                    @if (Auth::check() && Auth::user()->role === 'admin')
                        <a href="{{ route('admin.dashboard') }}" class="px-4 py-2 rounded-lg text-sm font-bold hover:bg-blue-600 transition {{ request()->routeIs('admin.dashboard') ? 'bg-blue-600' : '' }}">
                            ⚙️ Admin
                        </a>
                    
                    {{-- Links CONDICIONAIS para CLIENTE --}}
                    @elseif (Auth::check() && Auth::user()->role === 'client')
                        <a href="{{ route('inspections.create') }}" class="px-4 py-2 rounded-lg text-sm font-bold hover:bg-blue-600 transition {{ request()->routeIs('inspections.create') ? 'bg-blue-600' : '' }}">
                            ➕ Nova Vistoria
                        </a>
                        <a href="{{ route('inspections.history') }}" class="px-4 py-2 rounded-lg text-sm font-bold hover:bg-blue-600 transition {{ request()->routeIs('inspections.history') ? 'bg-blue-600' : '' }}">
                            📋 Meus Laudos
                        </a>
                    
                    {{-- Links CONDICIONAIS para ANALISTA --}}
                    @elseif (Auth::check() && Auth::user()->role === 'analyst')
                        <a href="{{ route('analyst.dashboard') }}" class="px-4 py-2 rounded-lg text-sm font-bold hover:bg-blue-600 transition {{ request()->routeIs('analyst.dashboard') ? 'bg-blue-600' : '' }}">
                            👨‍💼 Analista
                        </a>
                        <a href="{{ route('analyst.inspections.all') }}" class="px-4 py-2 rounded-lg text-sm font-bold hover:bg-blue-600 transition {{ request()->routeIs('analyst.inspections.all') ? 'bg-blue-600' : '' }}">
                            🔍 Todas Vistorias
                        </a>
                    @endif
                </div>
            </div>

            <div class="hidden sm:flex sm:items-center sm:ms-6 sm:gap-3">
                @if (Auth::check())
                    <x-dropdown align="right" width="48">
                        <x-slot name="trigger">
                            <button class="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-bold bg-blue-600 hover:bg-blue-500 text-white transition">
                                <span>👤 {{ Auth::user()->name }}</span>
                                <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
                                </svg>
                            </button>
                        </x-slot>

                        <x-slot name="content">
                            <a href="{{ route('profile.edit') }}" class="block px-4 py-2 text-sm text-gray-800 hover:bg-blue-100 transition font-semibold">
                                ⚡ Meu Perfil
                            </a>

                            <form method="POST" action="{{ route('logout') }}">
                                @csrf
                                <button type="submit" class="w-full text-left px-4 py-2 text-sm text-gray-800 hover:bg-blue-100 transition font-semibold">
                                    🚪 Sair
                                </button>
                            </form>
                        </x-slot>
                    </x-dropdown>
                @else
                    <a href="{{ route('login') }}" class="px-4 py-2 text-white hover:bg-blue-600 rounded-lg transition font-bold">
                        Login
                    </a>
                    <a href="{{ route('register') }}" class="px-4 py-2 bg-white text-blue-700 rounded-lg hover:bg-blue-50 transition font-bold">
                        Cadastro
                    </a>
                @endif
            </div>

            <div class="-me-2 flex items-center sm:hidden">
                <button @click="open = ! open" class="inline-flex items-center justify-center p-2 rounded-lg text-white hover:bg-blue-700 focus:outline-none transition">
                    <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                        <path :class="{'hidden': open, 'inline-flex': ! open }" class="inline-flex" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        <path :class="{'hidden': ! open, 'inline-flex': open }" class="hidden" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </div>
    </div>

    {{-- MENU RESPONSIVO (Mobile) --}}
    <div :class="{'block': open, 'hidden': ! open}" class="hidden sm:hidden bg-blue-800">
        <div class="pt-2 pb-3 space-y-1 px-2">
            <a href="{{ route('dashboard') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold {{ request()->routeIs('dashboard') ? 'bg-blue-700' : '' }}">
                📊 Painel
            </a>

            @if (Auth::check() && Auth::user()->role === 'admin')
                <a href="{{ route('admin.dashboard') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold {{ request()->routeIs('admin.dashboard') ? 'bg-blue-700' : '' }}">
                    ⚙️ Painel de Admin
                </a>
            @elseif (Auth::check() && Auth::user()->role === 'client')
                <a href="{{ route('inspections.create') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold {{ request()->routeIs('inspections.create') ? 'bg-blue-700' : '' }}">
                    ➕ Nova Vistoria
                </a>
                <a href="{{ route('inspections.history') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold {{ request()->routeIs('inspections.history') ? 'bg-blue-700' : '' }}">
                    📋 Meus Laudos
                </a>
            @elseif (Auth::check() && Auth::user()->role === 'analyst')
                <a href="{{ route('analyst.dashboard') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold {{ request()->routeIs('analyst.dashboard') ? 'bg-blue-700' : '' }}">
                    👨‍💼 Painel do Analista
                </a>
                <a href="{{ route('analyst.inspections.all') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold {{ request()->routeIs('analyst.inspections.all') ? 'bg-blue-700' : '' }}">
                    🔍 Todas as Vistorias
                </a>
            @endif
        </div>

        <div class="pt-4 pb-3 border-t border-blue-600 px-2">
            @if (Auth::check())
                <div class="px-2 py-2">
                    <div class="font-bold text-white text-lg">{{ Auth::user()->name }}</div>
                    <div class="text-sm text-blue-100 font-semibold">{{ Auth::user()->email }}</div>
                </div>

                <div class="mt-3 space-y-1">
                    <a href="{{ route('profile.edit') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold">
                        ⚡ Perfil
                    </a>

                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button type="submit" class="w-full text-left px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold">
                            🚪 Sair
                        </button>
                    </form>
                </div>
            @else
                <a href="{{ route('login') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold">
                    Login
                </a>
                <a href="{{ route('register') }}" class="block px-3 py-2 rounded-lg text-white hover:bg-blue-700 transition font-bold mt-2">
                    Cadastro
                </a>
            @endif
        </div>
    </div>
</nav>