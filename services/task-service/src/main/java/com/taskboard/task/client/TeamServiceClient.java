package com.taskboard.task.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class TeamServiceClient {

    private static final Logger log = LoggerFactory.getLogger(TeamServiceClient.class);

    private final RestTemplate restTemplate;
    private final String teamServiceUrl;

    public TeamServiceClient(RestTemplate restTemplate,
                              @Value("${team-service.url:http://localhost:8082}") String teamServiceUrl) {
        this.restTemplate = restTemplate;
        this.teamServiceUrl = teamServiceUrl;
    }

    public boolean memberExistsInTeam(Long teamId, Long memberId) {
        try {
            String url = String.format("%s/api/teams/%d/members/%d/exists", teamServiceUrl, teamId, memberId);
            Boolean exists = restTemplate.getForObject(url, Boolean.class);
            return Boolean.TRUE.equals(exists);
        } catch (Exception e) {
            log.warn("Failed to verify member in team service: {}", e.getMessage());
            return false;
        }
    }
}
