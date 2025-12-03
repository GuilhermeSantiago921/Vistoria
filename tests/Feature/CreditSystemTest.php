<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CreditSystemTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function admin_can_manage_client_credits()
    {
        // Criar usuários de teste
        $admin = User::factory()->create(['role' => 'admin']);
        $client = User::factory()->create(['role' => 'client', 'inspection_credits' => 5]);

        // Login como admin
        $this->actingAs($admin);

        // Testar página de gerenciar créditos
        $response = $this->get(route('admin.credits.manage'));
        $response->assertStatus(200);
        $response->assertSee($client->name);
        $response->assertSee('5'); // Créditos atuais

        // Testar adição de créditos
        $response = $this->post(route('admin.credits.add'), [
            'user_id' => $client->id,
            'credits' => 10,
            'reason' => 'Teste de adição'
        ]);

        $response->assertRedirect();
        $this->assertEquals(15, $client->fresh()->inspection_credits);

        // Testar definição de créditos
        $response = $this->post(route('admin.credits.set'), [
            'user_id' => $client->id,
            'credits' => 20,
            'reason' => 'Teste de definição'
        ]);

        $response->assertRedirect();
        $this->assertEquals(20, $client->fresh()->inspection_credits);
    }

    /** @test */
    public function client_can_see_their_credits()
    {
        $client = User::factory()->create(['role' => 'client', 'inspection_credits' => 3]);

        $this->actingAs($client);

        $response = $this->get(route('dashboard'));
        $response->assertStatus(200);
        $response->assertSee('3'); // Créditos no dashboard
    }

    /** @test */
    public function user_model_credit_methods_work()
    {
        $user = User::factory()->create(['inspection_credits' => 5]);

        // Testar hasCredits
        $this->assertTrue($user->hasCredits());

        // Testar consumeCredit
        $user->consumeCredit();
        $this->assertEquals(4, $user->fresh()->inspection_credits);

        // Testar addCredits
        $user->addCredits(10);
        $this->assertEquals(14, $user->fresh()->inspection_credits);

        // Testar setCredits
        $user->setCredits(25);
        $this->assertEquals(25, $user->fresh()->inspection_credits);

        // Testar quando não tem créditos
        $user->setCredits(0);
        $this->assertFalse($user->fresh()->hasCredits());
        $this->assertFalse($user->fresh()->consumeCredit());
    }

    /** @test */
    public function only_admin_can_access_credit_management()
    {
        $client = User::factory()->create(['role' => 'client']);
        $analyst = User::factory()->create(['role' => 'analyst']);

        // Cliente não pode acessar
        $this->actingAs($client);
        $response = $this->get(route('admin.credits.manage'));
        $response->assertStatus(403); // ou redirect dependendo do middleware

        // Analista não pode acessar
        $this->actingAs($analyst);
        $response = $this->get(route('admin.credits.manage'));
        $response->assertStatus(403); // ou redirect dependendo do middleware
    }
}
