/**
 * @dev Finite time contract
 */
contract FiniteTime {
    uint public start_time;
    uint public end_time;

    event Start();
    event Finish();

    /* This field have a `true` value between start and end time checkpoints */
    bool public is_alive = false;

    function FiniteTime(uint _start_sec, uint _duration_sec) {
        start_time = _start_sec;
        end_time   = start_time + _duration_sec;
        checkTime();
    }

    /**
     * @dev This method runs start and finish events
     */
    function checkTime() {
        if (now >= start_time) {
            if (now >= end_time) {
                is_alive = false;
                onFinish();
                Finish();
            } else {
                if (!is_alive) {
                    is_alive = true;
                    onStart();
                    Start();
                }
            }
        }
    }

    function onStart() internal {}
    function onFinish() internal {}
}
