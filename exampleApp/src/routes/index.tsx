import { component$ } from "@builder.io/qwik";
import type { DocumentHead } from "@builder.io/qwik-city";
import { routeLoader$ } from "@builder.io/qwik-city";
import { Link } from "@builder.io/qwik-city";
import axios from "axios";

export const useGetTime = routeLoader$(async () => {
  const { data } = await axios<{
    time: string;
  }>("https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
  return {
    data,
  };
});

export default component$(() => {
  const signal = useGetTime();

  return (
    <div>
      <h1>Qwik ISR</h1>
      <p>
        This page was rendered at <strong>{signal.value.data.time}</strong>.
        Update this page after a while and see if it works
      </p>
      <hr />
      <Link class="mindblow" href="/flower/">
        Blow my mind 🤯
      </Link>
      <Link class="todolist" href="/todolist/">
        TODO demo 📝
      </Link>
    </div>
  );
});

export const head: DocumentHead = {
  title: "Welcome to Qwik",
  meta: [
    {
      name: "description",
      content: "Qwik site description",
    },
  ],
};
