## Purpose

Core capability for storing, displaying, and navigating dated growth photos per plant. Allows users to track visual changes over time by adding dated photos to any plant's timeline.

## Requirements

### Requirement: User can add a dated photo to a plant
The system SHALL allow users to add a photo to any plant with an auto-assigned current date that the user can edit before saving.

#### Scenario: Add photo with default date
- **WHEN** user taps "Add photo" on a plant and selects an image
- **THEN** the system saves the image to local storage and creates a photo entry with today's date

#### Scenario: Add photo with edited date
- **WHEN** user taps "Add photo", selects an image, and changes the date before saving
- **THEN** the system saves the photo entry with the user-specified date

### Requirement: User can view plant photo timeline
The system SHALL display all photos for a plant in reverse-chronological order (newest first) with date labels.

#### Scenario: Timeline with multiple photos
- **WHEN** user opens the photo timeline for a plant with photos
- **THEN** the system displays photos ordered newest-first, each showing its date label

#### Scenario: Timeline with no photos
- **WHEN** user opens the photo timeline for a plant with no photos
- **THEN** the system displays an empty state message prompting to add the first photo

### Requirement: User can view a photo full-screen
The system SHALL allow users to tap a photo thumbnail to view it full-screen with swipe navigation between photos.

#### Scenario: Open full-screen view
- **WHEN** user taps a photo thumbnail in the timeline
- **THEN** the system opens the photo in full-screen mode

#### Scenario: Swipe between photos
- **WHEN** user is in full-screen view and swipes left or right
- **THEN** the system navigates to the next or previous photo in the timeline

#### Scenario: Close full-screen view
- **WHEN** user taps the back button or swipes down in full-screen view
- **THEN** the system returns to the timeline view

### Requirement: User can delete a photo from the timeline
The system SHALL allow users to remove a photo from a plant's timeline, with confirmation.

#### Scenario: Delete photo with confirmation
- **WHEN** user long-presses a photo and confirms deletion
- **THEN** the system removes the photo file from disk and deletes the metadata entry

#### Scenario: Cancel photo deletion
- **WHEN** user long-presses a photo and cancels the deletion dialog
- **THEN** the system does not modify the photo or its metadata

### Requirement: User can edit a photo date
The system SHALL allow users to change the date of an existing photo in the timeline.

#### Scenario: Edit photo date
- **WHEN** user taps the date label on a photo and selects a new date
- **THEN** the system updates the photo's date and re-sorts the timeline accordingly
