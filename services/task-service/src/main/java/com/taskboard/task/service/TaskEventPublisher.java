package com.taskboard.task.service;

import com.taskboard.task.config.RabbitMQConfig;
import com.taskboard.task.dto.TaskEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

@Service
public class TaskEventPublisher {

    private static final Logger log = LoggerFactory.getLogger(TaskEventPublisher.class);

    private final RabbitTemplate rabbitTemplate;

    public TaskEventPublisher(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void publishTaskAssigned(TaskEvent event) {
        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.TASK_EXCHANGE,
                    RabbitMQConfig.TASK_ASSIGNED_ROUTING_KEY,
                    event
            );
            log.info("Published task.assigned event for taskId={}", event.getTaskId());
        } catch (Exception e) {
            log.error("Failed to publish task.assigned event: {}", e.getMessage());
        }
    }

    public void publishTaskCompleted(TaskEvent event) {
        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.TASK_EXCHANGE,
                    RabbitMQConfig.TASK_COMPLETED_ROUTING_KEY,
                    event
            );
            log.info("Published task.completed event for taskId={}", event.getTaskId());
        } catch (Exception e) {
            log.error("Failed to publish task.completed event: {}", e.getMessage());
        }
    }

    public void publishTaskStatusChanged(TaskEvent event) {
        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.TASK_EXCHANGE,
                    RabbitMQConfig.TASK_STATUS_CHANGED_ROUTING_KEY,
                    event
            );
            log.info("Published task.status.changed event for taskId={}", event.getTaskId());
        } catch (Exception e) {
            log.error("Failed to publish task.status.changed event: {}", e.getMessage());
        }
    }
}
