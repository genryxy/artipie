/*
 * The MIT License (MIT) Copyright (c) 2020-2021 artipie.com
 * https://github.com/artipie/artipie/LICENSE.txt
 */
package com.artipie.docker;

import com.artipie.ArtipieServer;
import com.artipie.RepoConfigYaml;
import com.artipie.docker.junit.DockerClient;
import com.artipie.docker.junit.DockerClientSupport;
import java.nio.file.Path;
import java.util.Arrays;
import org.hamcrest.MatcherAssert;
import org.hamcrest.core.AllOf;
import org.hamcrest.core.StringContains;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

/**
 * Integration test for local Docker repositories.
 *
 * @since 0.10
 */
@SuppressWarnings("PMD.AvoidDuplicateLiterals")
@DockerClientSupport
final class DockerLocalIT {

    /**
     * Example docker image to use in tests.
     */
    private Image image;

    /**
     * Docker client.
     */
    private DockerClient client;

    /**
     * Tested Artipie server.
     */
    private ArtipieServer server;

    /**
     * Docker repository.
     */
    private String repository;

    @BeforeEach
    void setUp(@TempDir final Path root) throws Exception {
        this.server = new ArtipieServer(
            root, "my-docker", new RepoConfigYaml("docker").withFileStorage(root.resolve("data"))
        );
        final int port = this.server.start();
        this.repository = String.format("localhost:%d", port);
        this.image = this.prepareImage();
        final ArtipieServer.User user = ArtipieServer.ALICE;
        this.client.login(user.name(), user.password(), this.repository);
    }

    @AfterEach
    void tearDown() {
        this.server.stop();
    }

    @Test
    void shouldPush() throws Exception {
        final String output = this.client.run("push", this.image.remote());
        MatcherAssert.assertThat(
            output,
            new AllOf<>(
                Arrays.asList(
                    new StringContains(String.format("%s: Pushed", this.image.layer())),
                    new StringContains(String.format("latest: digest: %s", this.image.digest()))
                )
            )
        );
    }

    @Test
    @Disabled
    void shouldPullPushed() throws Exception {
        this.client.run("push", this.image.remote());
        this.client.run("image", "rm", this.image.name());
        this.client.run("image", "rm", this.image.remote());
        final String output = this.client.run("pull", this.image.remote());
        MatcherAssert.assertThat(
            output,
            new StringContains(
                String.format("Status: Downloaded newer image for %s", this.image.remote())
            )
        );
    }

    private Image prepareImage() throws Exception {
        final Image source = new Image.ForOs();
        this.client.run("pull", source.remoteByDigest());
        final String local = "my-docker/my-test";
        this.client.run("tag", source.remoteByDigest(), String.format("%s:latest", local));
        final Image img = new Image.From(
            this.repository,
            local,
            source.digest(),
            source.layer()
        );
        this.client.run("tag", source.remoteByDigest(), img.remote());
        return img;
    }
}
