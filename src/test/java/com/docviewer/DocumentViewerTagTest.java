package com.docviewer;

import com.docviewer.model.Document;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Unit tests for Document model and JSON stub parsing.
 * Verifies that the WireMock stub data loads correctly.
 */
class DocumentViewerTagTest {

    private static final Gson gson = new Gson();
    private static List<Document> documents;

    @BeforeAll
    static void loadDocuments() {
        InputStream is = DocumentViewerTagTest.class
                .getResourceAsStream("/wiremock/stubs/documents.json");
        if (is == null) {
            is = DocumentViewerTagTest.class
                    .getResourceAsStream("/documents.json");
        }
        assertThat(is).as("Stub JSON file must exist on classpath").isNotNull();

        try (InputStreamReader reader = new InputStreamReader(is)) {
            Type listType = new TypeToken<List<Document>>() {}.getType();
            documents = gson.fromJson(reader, listType);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse stub JSON", e);
        }
    }

    @Test
    void testStubDocumentsLoaded() {
        assertThat(documents).isNotEmpty();
    }

    @Test
    void testAllDocumentsHaveRequiredFields() {
        for (Document doc : documents) {
            assertThat(doc.getId())
                    .as("Document ID must not be null or empty")
                    .isNotBlank();
            assertThat(doc.getName())
                    .as("Document %s must have a name", doc.getId())
                    .isNotBlank();
            assertThat(doc.getType())
                    .as("Document %s must have a type", doc.getId())
                    .isIn("pdf", "jpeg", "tiff");
            assertThat(doc.getUrl())
                    .as("Document %s must have a URL", doc.getId())
                    .isNotBlank();
            assertThat(doc.getThumbnailUrl())
                    .as("Document %s must have a thumbnail URL", doc.getId())
                    .isNotBlank();
        }
    }

    @Test
    void testDocumentTypesAreValid() {
        List<String> types = documents.stream()
                .map(Document::getType)
                .distinct()
                .toList();
        assertThat(types)
                .as("Document types should be one of: pdf, jpeg, tiff")
                .allMatch(t -> t.equals("pdf") || t.equals("jpeg") || t.equals("tiff"));
    }

    @Test
    void testDocumentIdIsUnique() {
        List<String> ids = documents.stream()
                .map(Document::getId)
                .toList();
        assertThat(ids).doesNotHaveDuplicates();
    }

    @Test
    void testDocumentModelEquality() {
        Document doc1 = new Document("doc-001", "Test", "Desc", "pdf", "/url", "/thumb");
        Document doc2 = new Document("doc-001", "Test", "Desc", "pdf", "/url", "/thumb");
        Document doc3 = new Document("doc-002", "Other", "Desc", "image", "/url", "/thumb");

        assertThat(doc1).isEqualTo(doc2);
        assertThat(doc1).isNotEqualTo(doc3);
        assertThat(doc1).hasSameHashCodeAs(doc2);
    }

    @Test
    void testDocumentCount() {
        // There should be exactly 6 stub documents as defined
        assertThat(documents).hasSize(6);
    }

    @Test
    void testDocumentSizesArePositive() {
        for (Document doc : documents) {
            assertThat(doc.getSizeBytes())
                    .as("Document %s should have a positive size", doc.getId())
                    .isPositive();
        }
    }
}
