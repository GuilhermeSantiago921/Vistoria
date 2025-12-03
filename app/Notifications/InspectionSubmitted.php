<?php

namespace App\Notifications;

use App\Models\Inspection;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class InspectionSubmitted extends Notification implements ShouldQueue
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
                    ->subject('Vistoria Enviada com Sucesso - Sistema de Vistoria')
                    ->greeting('Olá ' . $notifiable->name . ',')
                    ->line('Sua solicitação de vistoria foi recebida com sucesso!')
                    ->line('**Detalhes da Vistoria:**')
                    ->line('• Placa do Veículo: ' . $this->inspection->vehicle->license_plate)
                    ->line('• Veículo: ' . $this->inspection->vehicle->brand . ' ' . $this->inspection->vehicle->model)
                    ->line('• Ano: ' . $this->inspection->vehicle->year)
                    ->line('• Data de Envio: ' . $this->inspection->created_at->format('d/m/Y H:i'))
                    ->line('• Status: Aguardando Análise')
                    ->line('')
                    ->line('Nossa equipe técnica irá analisar sua vistoria em breve. Você receberá uma nova notificação assim que a análise for concluída.')
                    ->action('Acompanhar Status', url('/dashboard'))
                    ->line('Obrigado por utilizar nosso sistema de vistoria!')
                    ->salutation('Atenciosamente, Equipe de Vistoria');
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
            'message' => 'Vistoria enviada com sucesso'
        ];
    }
}