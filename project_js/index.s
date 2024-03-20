// Initialize meeting
function initializeMeeting(mode) {
  window.VideoSDK.config(TOKEN);

  meeting = window.VideoSDK.initMeeting({
    meetingId: meetingId, // required
    name: "Thomas Edison", // required
    mode: mode,
  });

  meeting.join();

  meeting.on("meeting-joined", () => {
    textDiv.textContent = null;

    document.getElementById("grid-screen").style.display = "block";
    document.getElementById(
      "meetingIdHeading"
    ).textContent = `Meeting Id: ${meetingId}`;

    if (meeting.hlsState === Constants.hlsEvents.HLS_STOPPED) {
      hlsStatusHeading.textContent = "HLS has not stared yet";
    } else {
      hlsStatusHeading.textContent = `HLS Status: ${meeting.hlsState}`;
    }

    if (mode === Constants.modes.CONFERENCE) {
      // Pin the local participant if he joins in `CONFERENCE` mode
      meeting.localParticipant.pin();

      document.getElementById("speakerView").style.display = "block";
    }
  });

  meeting.on("meeting-left", () => {
    videoContainer.innerHTML = "";
  });

  meeting.on("hls-state-changed", (data) => {
    //
  });

  if (mode === Constants.modes.CONFERENCE) {
    // creating local participant
    createLocalParticipant();

    // setting local participant stream
    meeting.localParticipant.on("stream-enabled", (stream) => {
      setTrack(stream, null, meeting.localParticipant, true);
    });

    // participant joined
    meeting.on("participant-joined", (participant) => {
      if (participant.mode === Constants.modes.CONFERENCE) {
        participant.pin();

        let videoElement = createVideoElement(
          participant.id,
          participant.displayName
        );

        participant.on("stream-enabled", (stream) => {
          setTrack(stream, audioElement, participant, false);
        });

        let audioElement = createAudioElement(participant.id);
        videoContainer.appendChild(videoElement);
        videoContainer.appendChild(audioElement);
      }
    });

    // participants left
    meeting.on("participant-left", (participant) => {
      let vElement = document.getElementById(`f-${participant.id}`);
      vElement.remove(vElement);

      let aElement = document.getElementById(`a-${participant.id}`);
      aElement.remove(aElement);
    });
  }
}