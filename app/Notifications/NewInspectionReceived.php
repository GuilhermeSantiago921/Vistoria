<?php

namespace App\Notifications;

use App\Models\Inspection;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class NewInspectionReceived extends Notification implements ShouldQueue
{
    use Queueable;

    protected $inspection;

    /**
     * Create a new notification instance.
     */
    public function __construct(Inspection $inspection)
    {
        $this->inspection = $inspection;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->subject('🔔 Nova Vistoria para Análise - Sistema de Vistoria')
                    ->greeting('Olá ' . $notifiable->name . ',')
                    ->line('Uma nova solicitação de vistoria foi recebida e está aguardando sua análise.')
                    ->line('')
                    ->line('**Detalhes da Vistoria:**')
                    ->line('• ID da Vistoria: #' . $this->inspection->id)
                    ->line('• Placa do Veículo: ' . $this->inspection->vehicle->license_plate)
                    ->line('• Veículo: ' . $this->inspection->vehicle->brand . ' ' . $this->inspection->vehicle->model)
                    ->line('• Ano: ' . $this->inspection->vehicle->year)
                    ->line('• Cliente: ' . $this->inspection->client->name)
                    ->line('• Data de Envio: ' . $this->inspection->created_at->format('d/m/Y H:i'))
                    ->line('')
                    ->line('Por favor, acesse o sistema para iniciar a análise.')
                    ->action('Analisar Vistoria', route('analyst.inspections.show', $this->inspection->id))
                    ->line('Sistema de Vistoria - Painel do Mesário')
                    ->salutation('Sistema Automatizado');
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'inspection_id' => $this->inspection->id,
            'vehicle_plate' => $this->inspection->vehicle->license_plate,
            'client_name' => $this->inspection->client->name,
            'message' => 'Nova vistoria recebida para análise'
        ];
    }
}